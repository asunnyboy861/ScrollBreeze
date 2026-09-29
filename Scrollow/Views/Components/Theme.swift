import SwiftUI

enum Theme {
    static let deepSpace = Color(red: 0.05, green: 0.07, blue: 0.15)
    static let deepSpaceCard = Color(red: 0.09, green: 0.12, blue: 0.24)
    static let teal = Color(red: 0.24, green: 0.83, blue: 0.78)
    static let indigo = Color(red: 0.42, green: 0.45, blue: 0.95)
    static let ringGradient = LinearGradient(
        colors: [teal, indigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing)

    static var screenBackground: some View {
        ZStack {
            Color(Theme.deepSpace)
            RadialGradient(
                colors: [Theme.indigo.opacity(0.18), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 480)
        }
        .ignoresSafeArea()
    }

    static var accent: Color { teal }

    static func card(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? deepSpaceCard : Color(.secondarySystemBackground)
    }
}

extension View {
    func screenBackground() -> some View {
        background(Theme.screenBackground)
    }
}
