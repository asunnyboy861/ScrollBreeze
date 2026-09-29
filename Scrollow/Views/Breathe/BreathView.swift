import SwiftUI

struct BreathView: View {
    enum Source {
        case shield
        case home
    }

    let source: Source

    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = BreathModel()
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showTaskCenter = false
    @State private var celebrated = false

    private var freeWindowOnly: Bool {
        !purchaseManager.isPro && !purchaseManager.byoOwned && !purchaseManager.classicOwned
    }

    var body: some View {
        VStack(spacing: 20) {
            if model.isComplete {
                completeContent
            } else {
                breathingContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .preferredColorScheme(.dark)
        .onAppear {
            if model.cyclesCompleted == 0 && !model.isComplete {
                model.start()
            }
        }
        .sheet(isPresented: $showTaskCenter) {
            TaskCenterView()
        }
    }

    private var breathingContent: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("One scroll, three breaths.")
                .font(.title2.bold())
                .foregroundStyle(.white)
            BreathRing(model: model)
                .frame(width: 220, height: 220)
            Text(model.phase.rawValue)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
        }
    }

    private var completeContent: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Actually… no thanks 👋")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("Three breaths done. What now?")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            Button {
                celebrateGiveUp()
            } label: {
                VStack(spacing: 6) {
                    Text("Not now — I'm good")
                        .font(.headline)
                    Text("Close the feed for today")
                        .font(.caption)
                        .opacity(0.7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.1))
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .accessibilityLabel("Give up opening the app and reclaim time")

            if celebrated {
                Text("+\(AppGroupStore.reclaimedMinutesToday) min reclaimed today 💧+1")
                    .font(.headline)
                    .foregroundStyle(Theme.teal)
                    .transition(.opacity)
            } else {
                windowPicker
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var windowPicker: some View {
        VStack(spacing: 12) {
            Text("Or open a conscious window")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
            HStack(spacing: 12) {
                windowButton(5)
                if !freeWindowOnly { windowButton(15) }
                if !freeWindowOnly {
                    Button {
                        showTaskCenter = true
                    } label: {
                        VStack(spacing: 2) {
                            Text("Earn 30")
                                .font(.headline)
                            Text("with a task")
                                .font(.caption2)
                                .opacity(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.ringGradient)
                        .foregroundStyle(Theme.deepSpace)
                        .clipShape(Capsule())
                    }
                    .accessibilityLabel("Earn a 30 minute window with a replacement task")
                }
            }
            if freeWindowOnly {
                Text("15 & 30-minute windows are Pro. Breathing stays free forever.")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
    }

    private func windowButton(_ minutes: Int) -> some View {
        Button {
            unlock(minutes: minutes)
        } label: {
            Text("\(minutes) min")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.1))
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
        .accessibilityLabel("Open a \(minutes) minute window")
    }

    private func celebrateGiveUp() {
        let minutes = 8 + Int.random(in: 0...10)
        AppGroupStore.addReclaimed(minutes: minutes)
        AppGroupStore.addWaterDrops(1)
        AppGroupStore.appendEvent(kind: "giveUp", minutes: minutes)
        Haptics.success()
        withAnimation { celebrated = true }
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            dismiss()
        }
    }

    private func unlock(minutes: Int) {
        GateModel.shared.grant(windowMinutes: minutes)
        AppGroupStore.appendEvent(kind: "unlock", minutes: minutes)
        Haptics.medium()
        dismiss()
    }
}
