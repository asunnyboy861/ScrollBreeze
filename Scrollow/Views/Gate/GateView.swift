import FamilyControls
import SwiftUI

struct GateView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var gate = GateModel.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var authorizationFailed = false
    @State private var nightStart = Date()
    @State private var nightEnd = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !gate.isAuthorized {
                        authorizeCard
                    } else {
                        selectionCard
                        nightGateCard
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .screenBackground()
            .preferredColorScheme(.dark)
            .navigationTitle("Gate")
            .onAppear {
                Task { await gate.refreshAuthorization() }
                gate.startUnlockTimer()
                nightStart = timeFrom(minutes: AppGroupStore.nightStartMinutes == 0 ? 22 * 60 : AppGroupStore.nightStartMinutes)
                nightEnd = timeFrom(minutes: AppGroupStore.nightEndMinutes == 0 ? 7 * 60 : AppGroupStore.nightEndMinutes)
            }
            .alert("Authorization needed", isPresented: $authorizationFailed) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Scrollow needs Screen Time permission to guard your apps. You can grant it in system settings.")
            }
        }
    }

    private var authorizeCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 48))
                .foregroundStyle(Theme.ringGradient)
            Text("Arm your shield")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("Scrollow uses Apple's Screen Time APIs to guard the apps you pick. Works even when Scrollow is closed.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            Button {
                Task {
                    do {
                        try await gate.authorize()
                    } catch {
                        authorizationFailed = true
                    }
                }
            } label: {
                Text("Allow Screen Time access")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accent)
                    .foregroundStyle(Theme.deepSpace)
                    .clipShape(Capsule())
            }
            .accessibilityLabel("Authorize screen time access")
        }
        .padding(24)
        .background(Theme.card(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var selectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Guarded apps")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(guardedLabel)
                    .font(.caption)
                    .foregroundStyle(Theme.teal)
            }
            FamilyActivityPicker(selection: $gate.selection)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            if freeLimitReached {
                Text("Free tier guards 3 apps. Go Pro for unlimited.")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Button {
                gate.armGate()
                Haptics.medium()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                    Text("Apply shield now")
                }
                .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accent)
                    .foregroundStyle(Theme.deepSpace)
                    .clipShape(Capsule())
            }
            .accessibilityLabel("Apply shield now")
        }
        .padding(20)
        .background(Theme.card(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var nightGateCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: Binding(
                get: { AppGroupStore.nightGateOn },
                set: { on in
                    AppGroupStore.nightGateOn = on && (purchaseManager.isPro || purchaseManager.byoOwned || purchaseManager.classicOwned)
                    gate.scheduleNightGate()
                })) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Night gate")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Shield stays up during these hours")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .tint(Theme.accent)

            if AppGroupStore.nightGateOn {
                DatePicker("From", selection: $nightStart, displayedComponents: .hourAndMinute)
                    .foregroundStyle(.white)
                DatePicker("Until", selection: $nightEnd, displayedComponents: .hourAndMinute)
                    .foregroundStyle(.white)
            }

            if !purchaseManager.isPro && !purchaseManager.byoOwned && !purchaseManager.classicOwned {
                Text("Night gate is a Pro feature.")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(20)
        .background(Theme.card(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .onChange(of: nightStart) { _, value in
            AppGroupStore.nightStartMinutes = minutes(from: value)
            gate.scheduleNightGate()
        }
        .onChange(of: nightEnd) { _, value in
            AppGroupStore.nightEndMinutes = minutes(from: value)
            gate.scheduleNightGate()
        }
    }

    private var guardedLabel: String {
        let count = gate.guardedAppCount
        return count == 0 ? "None yet" : "\(count) app\(count == 1 ? "" : "s")"
    }

    private var freeLimitReached: Bool {
        gate.guardedAppCount >= 3 && !purchaseManager.isPro && !purchaseManager.byoOwned && !purchaseManager.classicOwned
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
