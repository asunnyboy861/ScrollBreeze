import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

extension FamilyActivitySelection {
    var isEmptySelection: Bool {
        applicationTokens.isEmpty && categoryTokens.isEmpty && webDomains.isEmpty
    }
}

@MainActor
final class GateModel: ObservableObject {
    static let shared = GateModel()

    let center = AuthorizationCenter.shared
    let store = ManagedSettingsStore(named: .init("scrollow.gate"))
    private let activityCenter = DeviceActivityCenter()

    @Published var selection: FamilyActivitySelection = FamilyActivitySelection() {
        didSet { persistSelection() }
    }
    @Published var isAuthorized = false
    @Published var unlockRemaining: TimeInterval = 0

    private var unlockTimer: Timer?

    init() {
        loadSelection()
    }

    func authorize() async throws {
        try await center.requestAuthorization(for: .individual)
        isAuthorized = true
    }

    func refreshAuthorization() async {
        let status = center.authorizationStatus
        isAuthorized = status == .approved
    }

    func armGate() {
        if AppGroupStore.isUnlocked {
            clearShield()
        } else {
            applyShield()
        }
    }

    private func applyShield() {
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
        AppGroupStore.shieldOn = true
    }

    func clearShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    func grant(windowMinutes m: Int) -> Date {
        let until = AppGroupStore.grant(windowMinutes: m)
        clearShield()
        AppGroupStore.shieldOn = false
        scheduleRelock(windowMinutes: m)
        startUnlockTimer()
        return until
    }

    private func scheduleRelock(windowMinutes m: Int) {
        let name = DeviceActivityName("scrollow.window")
        let now = Date()
        let end = now.addingTimeInterval(TimeInterval(m * 60))
        let schedule = DeviceActivitySchedule(
            intervalStart: Calendar.current.dateComponents([.hour, .minute, .second], from: now),
            intervalEnd: Calendar.current.dateComponents([.hour, .minute, .second], from: end),
            repeats: false)
        try? activityCenter.stopMonitoring([name])
        try? activityCenter.startMonitoring(name, during: schedule)
    }

    func scheduleNightGate() {
        let name = DeviceActivityName("scrollow.night")
        try? activityCenter.stopMonitoring([name])
        guard AppGroupStore.nightGateOn else { return }
        var start = DateComponents()
        start.hour = AppGroupStore.nightStartMinutes / 60
        start.minute = AppGroupStore.nightStartMinutes % 60
        var end = DateComponents()
        end.hour = AppGroupStore.nightEndMinutes / 60
        end.minute = AppGroupStore.nightEndMinutes % 60
        let schedule = DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: true)
        try? activityCenter.startMonitoring(name, during: schedule)
    }

    func relock() {
        applyShield()
        AppGroupStore.unlockUntil = .distantPast
        AppGroupStore.shieldOn = true
        unlockTimer?.invalidate()
        unlockRemaining = 0
    }

    func startUnlockTimer() {
        unlockTimer?.invalidate()
        updateUnlockRemaining()
        unlockTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateUnlockRemaining()
            }
        }
    }

    private func updateUnlockRemaining() {
        guard AppGroupStore.isUnlocked else {
            if unlockRemaining > 0 { relock() }
            return
        }
        unlockRemaining = AppGroupStore.unlockUntil.timeIntervalSinceNow
    }

    func isNightTime() -> Bool {
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let current = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        let start = AppGroupStore.nightStartMinutes
        let end = AppGroupStore.nightEndMinutes
        if start <= end {
            return current >= start && current < end
        }
        return current >= start || current < end
    }

    private func persistSelection() {
        if let data = try? JSONEncoder().encode(selection) {
            AppGroupStore.guardSelectionData = data
        }
    }

    private func loadSelection() {
        if let data = AppGroupStore.guardSelectionData,
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = decoded
        }
    }

    var guardedAppCount: Int {
        max(selection.applicationTokens.count, selection.categoryTokens.count)
    }
}
