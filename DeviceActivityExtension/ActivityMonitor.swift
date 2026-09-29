import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

final class ActivityMonitor: DeviceActivityMonitor {
    private let defaults = UserDefaults(suiteName: "group.com.scrollow.app")

    private var selectionData: Data? {
        defaults?.data(forKey: "guardSelection")
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        relock()
    }

    override func intervalDidStart(for activity: DeviceActivityName) {
        guard activity.rawValue == "scrollow.night" else { return }
        applyShield()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        guard activity.rawValue == "scrollow.window" || activity.rawValue == "scrollow.night" else { return }
        if activity.rawValue == "scrollow.night",
           let until = defaults?.object(forKey: "unlockUntil") as? Date,
           Date() < until {
            clearShield()
            return
        }
        relock()
    }

    private func clearShield() {
        let store = ManagedSettingsStore(named: .init("scrollow.gate"))
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    private func applyShield() {
        guard let data = selectionData,
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return }
        let store = ManagedSettingsStore(named: .init("scrollow.gate"))
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
        defaults?.set(true, forKey: "shieldOn")
    }

    private func relock() {
        applyShield()
        defaults?.set(Date.distantPast, forKey: "unlockUntil")
        defaults?.set(true, forKey: "shieldOn")
        AppGroupBridge.appendEvent(kind: "relock")
    }
}

enum AppGroupBridge {
    static func appendEvent(kind: String, minutes: Int = 0) {
        guard let defaults = UserDefaults(suiteName: "group.com.scrollow.app") else { return }
        var events = defaults.array(forKey: "pendingEvents") as? [[String: Any]] ?? []
        events.append([
            "kind": kind,
            "minutes": minutes,
            "date": Date().timeIntervalSince1970
        ])
        defaults.set(Array(events.suffix(400)), forKey: "pendingEvents")
    }
}
