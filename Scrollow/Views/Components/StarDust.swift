import SwiftUI

struct StarDust: View {
    let seed: Int

    @State private var appeared = false

    private var angle: Double { Double(seed) * 45 }

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: CGFloat(4 + seed % 3 * 2), height: CGFloat(4 + seed % 3 * 2))
            .offset(x: appeared ? cos(angle * .pi / 180) * 130 : 0,
                    y: appeared ? sin(angle * .pi / 180) * 130 : 0)
            .opacity(appeared ? 0 : 0.9)
            .animation(.easeOut(duration: 0.9).delay(Double(seed) * 0.05), value: appeared)
            .onAppear { appeared = true }
    }
}
