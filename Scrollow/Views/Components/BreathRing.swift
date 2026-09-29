import SwiftUI

struct BreathRing: View {
    @ObservedObject var model: BreathModel

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                StarDust(seed: i)
                    .opacity(model.showStardust ? 0.85 : 0)
                    .scaleEffect(model.showStardust ? 1 : 0.2)
            }
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Theme.teal, Theme.indigo],
                        center: .center,
                        startRadius: 10,
                        endRadius: 120))
                .frame(width: 180, height: 180)
                .scaleEffect(model.scale)
                .blur(radius: 6 - model.scale * 3)
                .shadow(color: Theme.teal.opacity(0.4), radius: 24)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Breathing guide")
        .accessibilityValue(model.phase.rawValue)
    }
}
