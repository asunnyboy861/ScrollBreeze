import Foundation
import SwiftUI
import UIKit

@MainActor
final class TaskModel: ObservableObject {
    enum Stage: Equatable {
        case idle
        case verifying
        case passed(windowMinutes: Int)
        case failed(reason: String)
        case honorMode(windowMinutes: Int)
        case unavailable
    }

    @Published var stage: Stage = .idle

    static let rewardMinutes = 30

    var canUseCloudAI: Bool {
        PurchaseManager.shared.isPro || PurchaseManager.shared.byoOwned
    }

    var hasAIBackend: Bool {
        canUseCloudAI && (EdgeAI.available || !Secrets.verificationProfiles().isEmpty)
    }

    func verify(task: ReclaimTask, imageData: Data?) async {
        guard canUseCloudAI else {
            stage = .unavailable
            return
        }
        stage = .verifying
        guard let imageData else {
            stage = .failed(reason: "We couldn't read that photo. Try again.")
            return
        }

        if let verdict = await EdgeAI.taskCheck(task: task, imageHint: task.prompt), verdict.pass {
            complete(task: task, minutes: Self.rewardMinutes)
            return
        }

        if !Secrets.verificationProfiles().isEmpty,
           let verdict = try? await MotionVerifier.shared.verify(
               task: task, jpeg: imageData, requestId: UUID()) {
            if verdict.pass {
                complete(task: task, minutes: Self.rewardMinutes)
            } else {
                Haptics.warning()
                stage = .failed(reason: friendlyRetry(verdict.reason))
            }
            return
        }

        grantHonorMode()
    }

    private func complete(task: ReclaimTask, minutes: Int) {
        GateModel.shared.grant(windowMinutes: minutes)
        AppGroupStore.addWaterDrops(1)
        AppGroupStore.appendEvent(kind: "taskPass", minutes: minutes, timestamp: Date())
        Haptics.success()
        stage = .passed(windowMinutes: minutes)
    }

    private func grantHonorMode() {
        let minutes = Self.rewardMinutes / 2
        GateModel.shared.grant(windowMinutes: minutes)
        AppGroupStore.appendEvent(kind: "taskHonor", minutes: minutes, timestamp: Date())
        Haptics.medium()
        stage = .honorMode(windowMinutes: minutes)
    }

    private func friendlyRetry(_ reason: String) -> String {
        if reason.lowercased().contains("duplicate") {
            return "That photo was already used. Take a fresh one."
        }
        return "Hmm — \(reason). Give it another shot, you've got this."
    }
}
