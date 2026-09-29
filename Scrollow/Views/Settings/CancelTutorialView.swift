import SwiftUI

struct CancelTutorialView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Cancel in 2 taps")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    stepRow(1, "Open the Settings app (the gray gears icon)")
                    stepRow(2, "Tap your name → Subscriptions")
                    stepRow(3, "Find Scrollow → Cancel Subscription")
                    Text("That's it. No dark patterns, no retention maze. Your Pro features stay active until the period ends.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(24)
                .frame(maxWidth: 720, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .screenBackground()
            .preferredColorScheme(.dark)
            .navigationTitle("How to cancel")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func stepRow(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(n)")
                .font(.headline)
                .frame(width: 30, height: 30)
                .background(Theme.accent)
                .foregroundStyle(Theme.deepSpace)
                .clipShape(Circle())
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }
}
