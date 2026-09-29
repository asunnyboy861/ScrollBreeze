import Foundation
import SwiftUI

@MainActor
final class BreathModel: ObservableObject {
    enum Phase: String {
        case inhale = "Breathe in"
        case exhale = "Breathe out"
        case done = "Nice."
    }

    @Published var phase: Phase = .inhale
    @Published var scale: CGFloat = 0.6
    @Published var cyclesCompleted = 0
    @Published var isComplete = false
    @Published var showStardust = false

    let totalCycles = 3
    private var startedAt = Date()

    var elapsedSeconds: Int { Int(Date().timeIntervalSince(startedAt)) }

    func start() {
        startedAt = Date()
        cyclesCompleted = 0
        isComplete = false
        showStardust = false
        phase = .inhale
        breatheIn()
    }

    private func breatheIn() {
        phase = .inhale
        withAnimation(.easeInOut(duration: 4)) { scale = 1.35 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            self?.breatheOut()
        }
    }

    private func breatheOut() {
        guard !isComplete else { return }
        phase = .exhale
        Haptics.light()
        withAnimation(.easeOut(duration: 4)) { scale = 0.6 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) { [weak self] in
            guard let self else { return }
            self.cyclesCompleted += 1
            if self.cyclesCompleted < self.totalCycles {
                self.breatheIn()
            } else {
                self.finish()
            }
        }
    }

    private func finish() {
        phase = .done
        isComplete = true
        showStardust = true
        Haptics.success()
    }
}
