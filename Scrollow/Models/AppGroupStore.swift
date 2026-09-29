import Foundation

enum AppGroupStore {
    static let suite = "group.com.scrollow.app"
    private static let d = UserDefaults(suiteName: suite)

    private static var defaults: UserDefaults {
        guard let d else { fatalError("App Group \(suite) unavailable") }
        return d
    }

    static var unlockUntil: Date {
        get { defaults.object(forKey: "unlockUntil") as? Date ?? .distantPast }
        set { defaults.set(newValue, forKey: "unlockUntil") }
    }

    static var isUnlocked: Bool { Date() < unlockUntil }

    static var shieldOn: Bool {
        get { defaults.bool(forKey: "shieldOn") }
        set { defaults.set(newValue, forKey: "shieldOn") }
    }

    static var waterDrops: Int {
        get { defaults.integer(forKey: "waterDrops") }
        set { defaults.set(newValue, forKey: "waterDrops") }
    }

    static var guardSelectionData: Data? {
        get { defaults.data(forKey: "guardSelection") }
        set { defaults.set(newValue, forKey: "guardSelection") }
    }

    static var intent: String {
        get { defaults.string(forKey: "intent") ?? "" }
        set { defaults.set(newValue, forKey: "intent") }
    }

    static var onboardingComplete: Bool {
        get { defaults.bool(forKey: "onboardingComplete") }
        set { defaults.set(newValue, forKey: "onboardingComplete") }
    }

    static var nightGateOn: Bool {
        get { defaults.bool(forKey: "nightGateOn") }
        set { defaults.set(newValue, forKey: "nightGateOn") }
    }

    static var nightStartMinutes: Int {
        get { defaults.integer(forKey: "nightStartMinutes") }
        set { defaults.set(newValue, forKey: "nightStartMinutes") }
    }

    static var nightEndMinutes: Int {
        get { defaults.integer(forKey: "nightEndMinutes") }
        set { defaults.set(newValue, forKey: "nightEndMinutes") }
    }

    static var dailyReminderOn: Bool {
        get { defaults.bool(forKey: "dailyReminderOn") }
        set { defaults.set(newValue, forKey: "dailyReminderOn") }
    }

    static var dailyReminderMinutes: Int {
        get { defaults.integer(forKey: "dailyReminderMinutes") }
        set { defaults.set(newValue, forKey: "dailyReminderMinutes") }
    }

    static var isPro: Bool {
        get { defaults.bool(forKey: "entitlementPro") }
        set { defaults.set(newValue, forKey: "entitlementPro") }
    }

    static var byoOwned: Bool {
        get { defaults.bool(forKey: "entitlementBYO") }
        set { defaults.set(newValue, forKey: "entitlementBYO") }
    }

    static var classicOwned: Bool {
        get { defaults.bool(forKey: "entitlementClassic") }
        set { defaults.set(newValue, forKey: "entitlementClassic") }
    }

    static var hasBYOKey: Bool {
        get { defaults.bool(forKey: "hasBYOKey") }
        set { defaults.set(newValue, forKey: "hasBYOKey") }
    }

    static var reclaimedDate: String {
        get { defaults.string(forKey: "reclaimedDate") ?? "" }
        set { defaults.set(newValue, forKey: "reclaimedDate") }
    }

    static var reclaimedMinutesToday: Int {
        get {
            guard reclaimedDate == Self.dayKey() else { return 0 }
            return defaults.integer(forKey: "reclaimedMinutes")
        }
        set {
            if reclaimedDate != Self.dayKey() {
                reclaimedDate = Self.dayKey()
                defaults.set(0, forKey: "reclaimedMinutes")
            }
            defaults.set(newValue, forKey: "reclaimedMinutes")
        }
    }

    static func addReclaimed(minutes: Int) {
        reclaimedMinutesToday += minutes
    }

    static func addWaterDrops(_ n: Int) {
        waterDrops += n
    }

    static func grant(windowMinutes m: Int) -> Date {
        let until = Date().addingTimeInterval(TimeInterval(m * 60))
        unlockUntil = until
        return until
    }

    static var pendingEvents: [[String: Any]] {
        get { defaults.array(forKey: "pendingEvents") as? [[String: Any]] ?? [] }
        set {
            let capped = newValue.suffix(400)
            defaults.set(Array(capped), forKey: "pendingEvents")
        }
    }

    static func appendEvent(kind: String, minutes: Int = 0, timestamp: Date = Date()) {
        var events = pendingEvents
        events.append(["kind": kind, "minutes": minutes, "date": timestamp.timeIntervalSince1970])
        pendingEvents = events
    }

    static func drainPendingEvents() -> [[String: Any]] {
        let events = pendingEvents
        pendingEvents = []
        return events
    }

    static func dayKey(date: Date = Date()) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
