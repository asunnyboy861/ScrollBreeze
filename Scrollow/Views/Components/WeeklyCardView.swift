import SwiftUI

struct WeeklyCardView: View {
    let card: HomeModel.WeeklyCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Theme.teal)
                Text("This week, in one line")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
            }
            Text(card.sentence)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card(ColorScheme.dark))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
