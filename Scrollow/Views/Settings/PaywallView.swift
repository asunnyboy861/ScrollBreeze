import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var purchasing = false
    @State private var message: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Image(systemName: "wind")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.ringGradient)
                    Text("ScrollBreeze Pro")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    Text("The breathing unlock is free forever.\nPro is for those who want more.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)

                    featureList

                    ForEach(subscriptionProducts, id: \.id) { product in
                        subscribeButton(product)
                    }

                    ForEach(lifetimeProducts, id: \.id) { product in
                        lifetimeButton(product)
                    }

                    if let message {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(Theme.teal)
                    }

                    Button {
                        Task {
                            await purchaseManager.restorePurchases()
                            message = "Purchases restored."
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundStyle(Theme.teal)
                    }

                    legalLinks

                    autoRenewalText
                }
                .padding(24)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .screenBackground()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .task {
                await purchaseManager.loadProducts()
            }
        }
    }

    private var subscriptionProducts: [Product] {
        purchaseManager.products.filter { $0.subscription != nil }
    }

    private var lifetimeProducts: [Product] {
        purchaseManager.products.filter { $0.subscription == nil }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow("lock.shield.fill", "Unlimited guarded apps")
            featureRow("camera.viewfinder", "AI-verified replacement tasks")
            featureRow("moon.stars.fill", "Night gate protection")
            featureRow("clock.arrow.circlepath", "15 & 30-minute windows")
            featureRow("key.fill", "BYO Lifetime: use your own AI key, unlimited")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Theme.card(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.teal)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }

    private func subscribeButton(_ product: Product) -> some View {
        Button {
            buy(product)
        } label: {
            VStack(spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                Text("\(product.displayPrice) / \(periodLabel(product))")
                    .font(.caption)
                    .opacity(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(purchasing ? Color.white.opacity(0.2) : Theme.accent)
            .foregroundStyle(Theme.deepSpace)
            .clipShape(Capsule())
        }
        .disabled(purchasing)
        .accessibilityLabel("Subscribe to \(product.displayName) for \(product.displayPrice) per \(periodLabel(product))")
    }

    private func lifetimeButton(_ product: Product) -> some View {
        Button {
            buy(product)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.id.contains("byo") ? "All Pro features + your own AI key" : "All non-AI features, forever")
                        .font(.caption2)
                        .opacity(0.8)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.headline)
            }
            .padding(16)
            .background(Color.white.opacity(0.08))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(purchasing)
        .accessibilityLabel("Buy \(product.displayName) for \(product.displayPrice), one time")
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/ScrollBreeze/privacy.html")!)
            Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/ScrollBreeze/terms.html")!)
        }
        .font(.caption2)
        .foregroundStyle(Theme.teal)
    }

    private var autoRenewalText: some View {
        Text("Subscriptions auto-renew unless canceled at least 24 hours before the end of the current period. 7-day free trial on the annual plan; terms shown before purchase.")
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.45))
            .multilineTextAlignment(.center)
    }

    private func periodLabel(_ product: Product) -> String {
        switch product.id {
        case "scrollow.pro.monthly": return "month"
        case "scrollow.pro.yearly": return "year"
        default: return "once"
        }
    }

    private func buy(_ product: Product) {
        purchasing = true
        Task {
            let success = await purchaseManager.purchase(product)
            purchasing = false
            message = success ? "You're in. Earned, not borrowed." : nil
        }
    }
}
