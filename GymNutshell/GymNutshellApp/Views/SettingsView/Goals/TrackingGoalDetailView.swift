// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Goals/TrackingGoalDetailView.swift
//
//  Propósito: Edita o valor de uma única meta diária fixa (ex: Água, Proteína, Sono).
//             Lê o valor atual do UserDefaults e grava de volta quando o usuário salva.
//             A VitaminD ganha um picker extra de categoria (Vitamina / Suplemento) que troca
//             a unidade (min → UI), o valor padrão (10 → 2000) e o incremento (5 → 500).
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-11.
// ⌘

import SwiftUI
import GymNutshellCore

/// Tela de detalhe pra editar uma meta fixa.
/// VitaminD tem uma seção extra pra trocar entre categoria Vitamina e Suplemento.
struct TrackingGoalDetailView: View {

    // MARK: - Configuração (passada pela TrackingGoalsSettingsView)

    let icon: String
    let title: String       // já localizado
    let unit: String
    let key: String         // chave do UserDefaults pra ler e escrever
    let fallback: Int       // valor usado se a chave nunca foi definida
    let increment: Int      // tamanho do passo pro Stepper

    @Environment(\.dismiss) private var dismiss

    // MARK: - Sistema de medidas

    @AppStorage(UserProfile.measurementSystemKey) private var measurementSystem: MeasurementSystem = .metric

    // MARK: - Modo VitaminD (só usado quando key == "tracking.vitaminD")

    @AppStorage(GoalCategory.vitaminDCategoryKey) private var vitaminDCategoryRaw: String = GoalCategory.vitamina.rawValue

    private var isVitaminD: Bool { key == "tracking.vitaminD" }

    // Categoria pendente, dirige toda a UI da tela (emoji, unidade, steppers).
    // Só é persistida em `save()`. Inicializada no `load()` a partir do AppStorage.
    @State private var pendingVitaminDCategory: GoalCategory = .vitamina

    // Emoji efetivo, VitaminD troca entre ☀️ e 💊 ao vivo conforme o picker.
    private var effectiveIcon: String {
        guard isVitaminD else { return icon }
        return pendingVitaminDCategory == .suplemento ? "💊" : "☀️"
    }

    // Unidade efetiva, usa modo VitaminD quando aplicável.
    private var effectiveUnit: String {
        guard isVitaminD else { return unit }
        return GoalCategory.vitaminDUnit(for: pendingVitaminDCategory)
    }

    // Fallback efetivo.
    private var effectiveFallback: Int {
        guard isVitaminD else { return fallback }
        return GoalCategory.vitaminDFallback(for: pendingVitaminDCategory)
    }

    // Incremento efetivo.
    private var effectiveIncrement: Int {
        guard isVitaminD else { return increment }
        return GoalCategory.vitaminDIncrement(for: pendingVitaminDCategory)
    }

    // Passo do Stepper que edita o incremento. Em UI (Suplemento) salta de 50 em 50;
    // demais casos vão de 1 em 1.
    private var incrementStepperStep: Int {
        isVitaminD && pendingVitaminDCategory == .suplemento ? 50 : 1
    }
    private var incrementStepperLowerBound: Int {
        incrementStepperStep
    }

    // Se essa meta precisa de conversão ml ↔ fl oz.
    private var isWaterImperial: Bool {
        key == "tracking.water" && measurementSystem == .us
    }

    // MARK: - Estado

    @State private var value: Int = 0
    @State private var currentIncrement: Int = 0

    // MARK: - Body

    var body: some View {
        Form {
            Section {
                Stepper(value: $value, in: currentIncrement...99999, step: currentIncrement) {
                    HStack {
                        Text(String(localized: "settings.goaldetail.stepper", bundle: .gymNutshellCore))
                        Spacer()
                        Text("\(value) \(effectiveUnit)")
                            .font(.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }

                // Passo do stepper de incremento: 1 por padrão, mas em UI (Suplemento)
                // queremos saltar de 50 em 50, número de UI é grande (500, 1000, 2000…),
                // 1 em 1 é tedioso demais.
                Stepper(value: $currentIncrement, in: incrementStepperLowerBound...99999, step: incrementStepperStep) {
                    HStack {
                        Text(String(localized: "settings.goaldetail.increment.stepper", bundle: .gymNutshellCore))
                        Spacer()
                        Text("\(currentIncrement) \(effectiveUnit)")
                            .font(.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            } footer: {
                Text(String(localized: "settings.goaldetail.footer", bundle: .gymNutshellCore))
                + Text("\n")
                + Text(String(localized: "settings.goaldetail.increment.footer", bundle: .gymNutshellCore))
            }

            // Seção exclusiva da VitaminD, permite trocar entre Vitamina e Suplemento.
            // A troca é só visual; persistência acontece no Salvar.
            if isVitaminD {
                Section {
                    Picker(String(localized: "settings.vitaminD.category.label", bundle: .gymNutshellCore),
                           selection: $pendingVitaminDCategory) {
                        Text(GoalCategory.vitamina.displayName).tag(GoalCategory.vitamina)
                        Text(GoalCategory.suplemento.displayName).tag(GoalCategory.suplemento)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text(String(localized: "settings.vitaminD.category.section", bundle: .gymNutshellCore))
                } footer: {
                    Text(String(localized: "settings.vitaminD.category.footer", bundle: .gymNutshellCore))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("\(effectiveIcon) \(title)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "settings.goaldetail.save", bundle: .gymNutshellCore)) {
                    save()
                    dismiss()
                }
                .disabled(value < currentIncrement || currentIncrement < 1)
            }
        }
        .onAppear {
            load()
        }
        // Trocou o modo no picker: ajusta valor e passo pros defaults do novo modo
        // (as unidades min ↔ UI não traduzem entre si). Persistência só no Salvar.
        .onChange(of: pendingVitaminDCategory) { _, newCategory in
            guard isVitaminD else { return }
            value = GoalCategory.vitaminDFallback(for: newCategory)
            currentIncrement = GoalCategory.vitaminDIncrement(for: newCategory)
        }
    }

    // MARK: - Carregar / Salvar

    private func load() {
        if isVitaminD {
            pendingVitaminDCategory = GoalCategory(rawValue: vitaminDCategoryRaw) ?? .vitamina
        }
        let stored = UserDefaults.standard.integer(forKey: key)
        let rawValue = stored > 0 ? stored : effectiveFallback
        if isWaterImperial {
            value = Int(UnitConverter.mlToFlOz(Double(rawValue)).rounded())
        } else {
            value = rawValue
        }
        let storedIncrement = UserDefaults.standard.integer(forKey: "\(key).increment")
        currentIncrement = storedIncrement > 0 ? storedIncrement : effectiveIncrement
    }

    private func save() {
        if isVitaminD {
            vitaminDCategoryRaw = pendingVitaminDCategory.rawValue
        }
        if isWaterImperial {
            UserDefaults.standard.set(Int(UnitConverter.flOzToMl(Double(value)).rounded()), forKey: key)
        } else {
            UserDefaults.standard.set(value, forKey: key)
        }
        UserDefaults.standard.set(currentIncrement, forKey: "\(key).increment")
    }
}
