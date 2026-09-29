import Foundation

enum MotionError: Error {
    case noProfile
    case badResponse
}

final class MotionVerifier {
    static let shared = MotionVerifier()
    private var inflight = Set<UUID>()

    func verify(task: ReclaimTask, jpeg: Data, requestId: UUID) async throws -> Verdict {
        guard !inflight.contains(requestId) else {
            return Verdict(pass: false, confidence: 0, reason: "duplicate request")
        }
        inflight.insert(requestId)
        defer { inflight.remove(requestId) }

        let profiles = Secrets.verificationProfiles()
        guard !profiles.isEmpty else { throw MotionError.noProfile }

        for profile in profiles {
            if let verdict = try? await call(profile: profile, task: task, jpeg: jpeg) {
                return verdict
            }
        }
        throw MotionError.badResponse
    }

    private func call(profile: AIProfile, task: ReclaimTask, jpeg: Data) async throws -> Verdict {
        var request = URLRequest(url: profile.endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("Bearer \(profile.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let b64 = jpeg.base64EncodedString()
        let body: [String: Any] = [
            "model": profile.model,
            "temperature": 0.1,
            "response_format": ["type": "json_object"],
            "messages": [[
                "role": "user",
                "content": [
                    ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(b64)"]],
                    ["type": "text", "text":
                        "Task: \(task.title). \(task.prompt). Does the photo show the user doing this task? " +
                        "Reply with JSON only: {\"pass\":bool,\"confidence\":0.0-1.0,\"reason\":\"max 12 words\"}"]
                ]
            ]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(GLMResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw MotionError.badResponse
        }
        return try JSONDecoder().decode(Verdict.self, from: Data(content.utf8))
    }
}

private struct GLMResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
