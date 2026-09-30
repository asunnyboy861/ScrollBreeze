import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    @State private var showContact = false
    @State private var showBYOKey = false
    @State private var showCancelTutorial = false
    @State private var reminderOn = AppGroupStore.dailyReminderOn
    @State private var reminderTime = Date()

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                proSection
                aiSection
                reminderSection
                legalSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .screenBackground()
            .preferredColorScheme(.dark)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(isPresented: $showContact) { ContactSupportView() }
            .sheet(isPresented: $showBYOKey) { BYOKeyView() }
            .sheet(isPresented: $showCancelTutorial) { CancelTutorialView() }
            .onAppear {
                reminderTime = timeFrom(minutes: AppGroupStore.dailyReminderMinutes == 0 ? 9 * 60 : AppGroupStore.dailyReminderMinutes)
            }
        }
    }

    private var proSection: some View {
        Section {
            if purchaseManager.isPro || purchaseManager.byoOwned || purchaseManager.classicOwned {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Pro unlocked — thanks for supporting ScrollBreeze")
                }
                .foregroundStyle(Theme.teal)
                Button {
                    Task { await purchaseManager.restorePurchases() }
                } label: {
                    Text("Restore Purchases")
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Upgrade to Pro")
                }
                .foregroundStyle(Theme.teal)
                }
            }
        } header: {
            Text("ScrollBreeze Pro")
                .foregroundStyle(.white.opacity(0.6))
        } footer: {
            Text("Free tier is free forever. Cancel in 2 taps: Settings → Subscription.")
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var aiSection: some View {
        Section {
            HStack {
                Image(systemName: "apple.logo")
                    .foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Apple Intelligence")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(EdgeAI.available ? "On-device AI available (iOS 26+)" : "Requires iOS 26+. Configure a custom API key below.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            Button {
                showBYOKey = true
            } label: {
                HStack {
                    Label("Custom API Key", systemImage: "key.fill")
                    Spacer()
                    if AppGroupStore.hasBYOKey {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Theme.teal)
                    }
                }
            }
            .foregroundStyle(.white)
        } header: {
            Text("AI Configuration")
                .foregroundStyle(.white.opacity(0.6))
        } footer: {
            Text("Photos are processed in memory only — never stored, never used for training.")
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var reminderSection: some View {
        Section {
            Toggle("Gentle daily reminder", isOn: $reminderOn)
                .tint(Theme.accent)
                .foregroundStyle(.white)
                .onChange(of: reminderOn) { _, on in
                    AppGroupStore.dailyReminderOn = on
                    NotificationScheduler.update(on: on, at: reminderTime)
                }
            if reminderOn {
                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .foregroundStyle(.white)
                    .onChange(of: reminderTime) { _, value in
                        AppGroupStore.dailyReminderMinutes = minutes(from: value)
                        NotificationScheduler.update(on: true, at: value)
                    }
            }
        } header: {
            Text("Notifications")
                .foregroundStyle(.white.opacity(0.6))
        } footer: {
            Text("At most one gentle reminder per day, at the time you choose.")
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var legalSection: some View {
        Section {
            Link(destination: URL(string: "https://asunnyboy861.github.io/ScrollBreeze/support.html")!) {
                HStack(spacing: 8) {
                    Image(systemName: "questionmark.circle")
                    Text("Support")
                }
            }
            .foregroundStyle(.white)
            Link(destination: URL(string: "https://asunnyboy861.github.io/ScrollBreeze/privacy.html")!) {
                HStack(spacing: 8) {
                    Image(systemName: "hand.raised")
                    Text("Privacy Policy")
                }
            }
            .foregroundStyle(.white)
            Link(destination: URL(string: "https://asunnyboy861.github.io/ScrollBreeze/terms.html")!) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                    Text("Terms of Use")
                }
            }
            .foregroundStyle(.white)
            Button {
                showContact = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "envelope")
                    Text("Contact Support")
                }
            }
            .foregroundStyle(.white)
            Button {
                showCancelTutorial = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.uturn.backward")
                    Text("How to cancel subscription")
                }
            }
            .foregroundStyle(.white)
        } header: {
            Text("Legal & Support")
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("ScrollBreeze — like pillow: scroll slow, sleep deep.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.5))
            }
        } footer: {
            Text(appVersion)
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private func timeFrom(minutes: Int) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = minutes / 60
        comps.minute = minutes % 60
        return Calendar.current.date(from: comps) ?? Date()
    }

    private func minutes(from date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }
}
