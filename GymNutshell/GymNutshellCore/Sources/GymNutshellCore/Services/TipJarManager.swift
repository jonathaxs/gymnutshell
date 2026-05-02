// ⌘
//  GymNutshellCore/Services/TipJarManager.swift
//
//  Propósito: Carrega e processa as compras consumíveis do Tip Jar via StoreKit 2.
//             Sem persistência — não é necessário restaurar; cada gorjeta é única.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-30.
// ⌘

import Foundation
import StoreKit

/// Gerencia os produtos consumíveis do Tip Jar.
/// Os identificadores correspondem aos produtos cadastrados no App Store Connect.
@MainActor
public final class TipJarManager: ObservableObject {

    public static let shared = TipJarManager()

    /// Identificadores dos consumíveis cadastrados no App Store Connect.
    /// Mantenha em sincronia com a configuração de produtos.
    public static let productIDs: [String] = [
        "com.jonathaxs.gymnutshell.tip.small",
        "com.jonathaxs.gymnutshell.tip.medium",
        "com.jonathaxs.gymnutshell.tip.large"
    ]

    @Published public private(set) var products: [Product] = []
    @Published public private(set) var isLoading: Bool = false

    private init() {}

    /// Carrega os produtos. Idempotente — só busca uma vez por sessão.
    public func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        if let fetched = try? await Product.products(for: Self.productIDs) {
            products = fetched.sorted { $0.price < $1.price }
        }
    }

    public enum PurchaseOutcome: Sendable {
        case success
        case userCancelled
        case pending
        case failed(String)
    }

    /// Executa a compra do produto. Finaliza a transação imediatamente após verificação.
    /// Como é consumível e não há nada pra desbloquear no app, não persistimos nada.
    public func purchase(_ product: Product) async -> PurchaseOutcome {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    return .success
                case .unverified(_, let error):
                    return .failed(error.localizedDescription)
                }
            case .userCancelled:
                return .userCancelled
            case .pending:
                return .pending
            @unknown default:
                return .failed("unknown")
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}
