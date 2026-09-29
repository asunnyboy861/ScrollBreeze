import SwiftData
import SwiftUI

@main
struct ScrollowApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showBreathSheet = false
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    let container = try? ModelContainer(for: GateEvent.self)

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding && AppGroupStore.onboardingComplete {
                    RootTabView()
                } else {
                    OnboardingView(onComplete: {
                        hasSeenOnboarding = true
                    })
                }
            }
            .onOpenURL { url in
                if url.absoluteString.contains("breathe") {
                    showBreathSheet = true
                }
            }
            .sheet(isPresented: $showBreathSheet) {
                BreathView(source: .shield)
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                ingestPendingEvents()
                if !AppGroupStore.onboardingComplete {
                    showOnboarding = true
                }
                if AppGroupStore.isUnlocked {
                    GateModel.shared.startUnlockTimer()
                }
            }
        }
        .modelContainer(container ?? (try! ModelContainer(for: GateEvent.self, configurations: .init(isStoredInMemoryOnly: true))))
    }

    private func ingestPendingEvents() {
        let events = AppGroupStore.drainPendingEvents()
        guard !events.isEmpty else { return }
        let context = container?.mainContext
        for event in events {
            guard let kind = event["kind"] as? String else { continue }
            let minutes = event["minutes"] as? Int ?? 0
            let timestamp = Date(timeIntervalSince1970: event["date"] as? Double ?? Date().timeIntervalSince1970)
            context?.insert(GateEvent(date: timestamp, kind: kind, minutes: minutes, detail: "extension"))
        }
        try? context?.save()
    }
}
