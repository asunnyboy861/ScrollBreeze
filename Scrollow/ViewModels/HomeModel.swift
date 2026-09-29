import Foundation
import SwiftData
import SwiftUI

@MainActor
final class HomeModel: ObservableObject {
    @Published var reclaimedToday: Int = 0
    @Published var waterDrops: Int = 0
    @Published var weeklyDrops: Int = 0
    @Published var isUnlocked = false
    @Published var unlockRemaining: TimeInterval = 0
    @Published var guardedCount = 0
    @Published var weeklyCard: WeeklyCard?

    struct WeeklyCard: Identifiable {
        let id = UUID()
        let sentence: String
        let suggestion: String?
        var suggestionAppliesNightGate: Bool = false
    }

    private var timer: Timer?

    func start() {
        refresh()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.refresh() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        reclaimedToday = AppGroupStore.reclaimedMinutesToday
        waterDrops = AppGroupStore.waterDrops
        isUnlocked = AppGroupStore.isUnlocked
        if isUnlocked {
            unlockRemaining = AppGroupStore.unlockUntil.timeIntervalSinceNow
        }
        guardedCount = GateModel.shared.guardedAppCount
    }
}
