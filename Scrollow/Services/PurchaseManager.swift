import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    static let productIds = [
        "scrollow.pro.monthly",
        "scrollow.pro.yearly",
        "scrollow.byo.lifetime",
        "scrollow.classic.lifetime"
    ]

    @Published var isPro: Bool = false
    @Published var byoOwned: Bool = false
    @Published var classicOwned: Bool = false
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var loadError: String?

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await checkPurchased()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    var anyPaidTier: Bool { isPro || byoOwned || classicOwned }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: Self.productIds)
            loadError = nil
        } catch {
            loadError = "Unable to load purchase options."
        }
        isLoading = false
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await checkPurchased()
                    return true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            loadError = "Purchase failed: \(error.localizedDescription)"
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchased()
        } catch {
            loadError = "Restore failed: \(error.localizedDescription)"
        }
    }

    func checkPurchased() async {
        let monthly = await hasEntitlement("scrollow.pro.monthly")
        let yearly = await hasEntitlement("scrollow.pro.yearly")
        isPro = monthly || yearly
        byoOwned = await hasEntitlement("scrollow.byo.lifetime")
        classicOwned = await hasEntitlement("scrollow.classic.lifetime")
        AppGroupStore.isPro = isPro || byoOwned || classicOwned
        AppGroupStore.byoOwned = byoOwned
        AppGroupStore.classicOwned = classicOwned
    }

    private func hasEntitlement(_ id: String) async -> Bool {
        guard let result = await Transaction.currentEntitlement(for: id) else { return false }
        if case .verified(let transaction) = result {
            return transaction.revocationDate == nil
        }
        return false
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    Task { @MainActor [weak self] in
                        await self?.checkPurchased()
                    }
                }
            }
        }
    }
}
