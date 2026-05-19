// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Profile/TipJarView.swift
//
//  Propósito: Sheet apresentando os tiers de gorjeta (consumíveis IAP) pra apoiar o desenvolvedor.
//             Carrega produtos via TipJarManager (StoreKit 2), executa a compra e mostra agradecimento.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-30.
// ⌘

import SwiftUI
import StoreKit
import GymNutshellCore

struct TipJarView: View {

    @StateObject private var manager = TipJarManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var purchasingProductID: String? = nil
    @State private var showThanks: Bool = false
    @State private var errorMessage: String? = nil

    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color { (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(String(localized: "tipjar.description", bundle: .gymNutshellCore))
                        .font(.body)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                if manager.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                } else if manager.products.isEmpty {
                    Section {
                        Text(String(localized: "tipjar.error", bundle: .gymNutshellCore))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    Section {
                        ForEach(manager.products, id: \.id) { product in
                            tipRow(product)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "tipjar.title", bundle: .gymNutshellCore))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel", bundle: .gymNutshellCore)) { dismiss() }
                }
            }
            .task { await manager.loadProducts() }
            .alert(
                String(localized: "tipjar.thanks.title", bundle: .gymNutshellCore),
                isPresented: $showThanks
            ) {
                Button("OK") { dismiss() }
            } message: {
                Text(String(localized: "tipjar.thanks.message", bundle: .gymNutshellCore))
            }
            .alert(
                "",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    @ViewBuilder
    private func tipRow(_ product: Product) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(product.displayName)
                    .font(.subheadline.weight(.semibold))
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(String(format: String(localized: "a11y.tipjar.row.format",
                                                     bundle: .gymNutshellCore),
                                       product.displayName, product.description))
            Spacer()
            Button {
                purchase(product)
            } label: {
                if purchasingProductID == product.id {
                    ProgressView()
                        .frame(minWidth: 60)
                } else {
                    Text(product.displayPrice)
                        .font(.subheadline.weight(.semibold))
                }
            }
            .tint(accentColor)
            .buttonStyle(.borderedProminent)
            .disabled(purchasingProductID != nil)
            .accessibilityLabel(String(format: String(localized: "a11y.tipjar.buy.label.format",
                                                     bundle: .gymNutshellCore),
                                       product.displayName, product.displayPrice))
            .accessibilityHint(String(localized: "a11y.tipjar.buy.hint", bundle: .gymNutshellCore))
        }
    }

    private func purchase(_ product: Product) {
        purchasingProductID = product.id
        Task {
            let outcome = await manager.purchase(product)
            await MainActor.run {
                purchasingProductID = nil
                switch outcome {
                case .success:
                    showThanks = true
                case .userCancelled, .pending:
                    break
                case .failed(let message):
                    errorMessage = message
                }
            }
        }
    }
}
