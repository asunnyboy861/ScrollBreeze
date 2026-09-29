import SwiftUI

struct WaterDropBottle: View {
    let drops: Int

    private let weeklyCapacity = 7

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Life drops")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(drops) 💧")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.teal)
            }
            HStack(spacing: 8) {
                ForEach(0..<weeklyCapacity, id: \.self) { i in
                    Image(systemName: "drop.fill")
                        .font(.body)
                        .foregroundStyle(i < min(drops, weeklyCapacity) ? Theme.teal : Color.white.opacity(0.15))
                }
                if drops > weeklyCapacity {
                    Text("+\(drops - weeklyCapacity)")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.teal)
                }
                Spacer()
            }
            Text("One drop every time you pause or earn a window.")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(18)
        .background(Theme.card(ColorScheme.dark))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Life drops: \(drops)")
    }
}
