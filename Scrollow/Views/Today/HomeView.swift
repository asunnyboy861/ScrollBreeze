import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var home = HomeModel()
    @State private var showBreath = false
    @State private var showSettings = false
    @State private var weekly = WeeklyModel()
    @State private var showWeeklyCard = false
    @State private var applyNightGate = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    heroNumber
                    gateStatus
                    waterBottle
                    weeklySection
                    breatheButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
            .screenBackground()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showBreath) {
                BreathView(source: .home)
            }
            .sheet(isPresented: $showWeeklyCard) {
                WeeklyCardDetail(weekly: weekly, applyNightGate: $applyNightGate)
                    .presentationDetents([.medium])
            }
            .onAppear {
                home.start()
                Task { await weekly.generate(context: modelContext) }
            }
            .onDisappear { home.stop() }
        }
    }

    private var heroNumber: some View {
        VStack(spacing: 6) {
            Text("\(home.reclaimedToday)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            Text("min reclaimed today")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.6))
            Text("Every pause counts. Nothing here wants you stuck.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(.top, 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(home.reclaimedToday) minutes reclaimed today")
    }

    @ViewBuilder
    private var gateStatus: some View {
        HStack(spacing: 12) {
            Image(systemName: home.isUnlocked ? "lock.open.fill" : "lock.shield.fill")
                .foregroundStyle(Theme.teal)
            VStack(alignment: .leading, spacing: 2) {
                Text(home.isUnlocked
                    ? "Door open — \(Int(home.unlockRemaining / 60) + 1) min left"
                    : "Shield armed on \(home.guardedCount) apps")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(home.isUnlocked ? "Enjoy it. We'll hold the door." : "Tap the shield below to breathe")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding(18)
        .background(Theme.card(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var waterBottle: some View {
        WaterDropBottle(drops: home.waterDrops)
    }

    private var weeklySection: some View {
        Group {
            if let card = weekly.card {
                Button {
                    showWeeklyCard = true
                } label: {
                    WeeklyCardView(card: card)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Weekly insight card")
            }
        }
    }

    private var breatheButton: some View {
        Button {
            showBreath = true
        } label: {
            HStack {
                Image(systemName: "wind")
                Text("Breathe & reclaim")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Theme.ringGradient)
            .foregroundStyle(Theme.deepSpace)
            .clipShape(Capsule())
        }
        .padding(.bottom, 24)
        .accessibilityLabel("Start a breathing session")
    }
}

struct WeeklyCardDetail: View {
    @ObservedObject var weekly: WeeklyModel
    @Binding var applyNightGate: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            if let card = weekly.card {
                Text(card.sentence)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                if let suggestion = card.suggestion {
                    Text(suggestion)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                    if card.suggestionAppliesNightGate {
                        Button {
                            AppGroupStore.nightGateOn = true
                            AppGroupStore.nightStartMinutes = 22 * 60
                            AppGroupStore.nightEndMinutes = 7 * 60
                            GateModel.shared.scheduleNightGate()
                            Haptics.success()
                            dismiss()
                        } label: {
                            Text("One tap: yes — night gate 10pm–7am")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Theme.accent)
                                .foregroundStyle(Theme.deepSpace)
                                .clipShape(Capsule())
                        }
                        .accessibilityLabel("Enable night gate")
                    }
                }
            } else if weekly.isLoading {
                ProgressView()
            }
        }
        .padding(24)
        .screenBackground()
        .preferredColorScheme(.dark)
    }
}
