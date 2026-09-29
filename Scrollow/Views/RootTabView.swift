import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Today", systemImage: "drop.circle") }
                .tag(0)
            GateView()
                .tabItem { Label("Gate", systemImage: "lock.shield") }
                .tag(1)
        }
        .tint(Theme.accent)
    }
}
