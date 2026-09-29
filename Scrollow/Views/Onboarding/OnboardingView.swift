import FamilyControls
import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var step = 0
    @State private var selection = FamilyActivitySelection()
    @State private var intents = ["Sleep better", "Focus at work", "Be present"]
    @State private var selectedIntent: String?
    @State private var trialBreath = BreathModel()
    @State private var showEasterEgg = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Theme.accent : Color.white.opacity(0.15))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            switch step {
            case 0: pickApps
            case 1: pickIntent
            default: trialBreathView
            }
        }
        .screenBackground()
        .preferredColorScheme(.dark)
    }

    private var pickApps: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.ringGradient)
            Text("Pick up to 3 apps you want to scroll less")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            Text("Your shield is armed the moment you're done.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            FamilyActivityPicker(selection: $selection)
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Button {
                AppGroupStore.guardSelectionData = try? JSONEncoder().encode(selection)
                GateModel.shared.selection = selection
                step = 1
            } label: {
                Text(selection.isEmptySelection ? "Pick at least one app" : "That's it — continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selection.isEmptySelection ? Color.white.opacity(0.12) : Theme.accent)
                    .foregroundStyle(selection.isEmptySelection ? .white.opacity(0.5) : Theme.deepSpace)
                    .clipShape(Capsule())
            }
            .disabled(selection.isEmptySelection)
            .padding(.horizontal, 24)
            .accessibilityLabel("Continue to next onboarding step")
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var pickIntent: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Why do you want to scroll less?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            Text("One tap. You can change this anytime.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            ForEach(intents, id: \.self) { intent in
                Button {
                    selectedIntent = intent
                    AppGroupStore.intent = intent
                    step = 2
                } label: {
                    HStack {
                        Text(intent)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .accessibilityLabel("Choose intent \(intent)")
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var trialBreathView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Try it: breathe with this circle")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("Three breaths. About 8 seconds.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            BreathRing(model: trialBreath)
                .frame(width: 220, height: 220)

            Text(trialBreath.phase.rawValue)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))

            if showEasterEgg {
                Text("You just said no to an imaginary Instagram.")
                    .font(.footnote)
                    .foregroundStyle(Theme.teal)
                    .transition(.opacity)
            }

            Button {
                finishOnboarding()
            } label: {
                Text(trialBreath.isComplete ? "Done — shield me" : "Skip the practice")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(trialBreath.isComplete ? Theme.accent : Color.white.opacity(0.12))
                    .foregroundStyle(trialBreath.isComplete ? Theme.deepSpace : .white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .accessibilityLabel("Finish onboarding")
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            trialBreath.start()
            Task {
                try? await Task.sleep(nanoseconds: 9_500_000_000)
                withAnimation { showEasterEgg = true }
            }
        }
    }

    private func finishOnboarding() {
        GateModel.shared.armGate()
        AppGroupStore.onboardingComplete = true
        onComplete()
    }
}
