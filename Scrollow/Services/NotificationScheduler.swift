import SwiftUI
import UserNotifications

enum NotificationScheduler {
    static func update(on: Bool, at time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["scrollow.dailyReminder"])
        guard on else { return }
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let content = UNMutableNotificationContent()
            content.title = "Time to reclaim?"
            content.body = "One breath. Eight seconds. Your feed can wait."
            content.sound = .default
            let request = UNNotificationRequest(
                identifier: "scrollow.dailyReminder", content: content, trigger: trigger)
            center.add(request)
        }
    }
}
