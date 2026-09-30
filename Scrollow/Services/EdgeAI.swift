import Foundation
import FoundationModels

enum EdgeAI {
    static var available: Bool {
        if #available(iOS 26, *) {
            return true
        }
        return false
    }

    static func weeklyInsight(summary: String) async -> String? {
        guard #available(iOS 26, *) else { return nil }
        return await FoundationModelsBridge.insight(prompt:
            "You are ScrollBreeze, a warm screen-time companion. Based on this weekly activity summary, " +
            "write ONE friendly sentence (max 25 words) followed by ONE short suggestion. " +
            "Never use charts or lists. Never shame the user. Summary: \(summary)")
    }

    static func taskCheck(task: ReclaimTask, imageHint: String) async -> Verdict? {
        guard #available(iOS 26, *) else { return nil }
        let prompt =
            "A user completed the task: \(task.title). Description: \(task.prompt). " +
            "Photo context: \(imageHint). " +
            "Decide if it plausibly shows the task being done. " +
            "Reply ONLY JSON: {\"pass\":bool,\"confidence\":0.0-1.0,\"reason\":\"max 12 words\"}"
        return await FoundationModelsBridge.verdict(prompt: prompt)
    }
}

@available(iOS 26, *)
private enum FoundationModelsBridge {
    static func insight(prompt: String) async -> String? {
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return nil
        }
    }

    static func verdict(prompt: String) async -> Verdict? {
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            guard let data = response.content.data(using: .utf8) else { return nil }
            return try JSONDecoder().decode(Verdict.self, from: data)
        } catch {
            return nil
        }
    }
}
