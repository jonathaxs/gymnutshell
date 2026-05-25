// ⌘
//  GymNutshell/GymNutshellApp/Views/WelcomeView/Steps/WelcomeSummaryStep.swift
//
//  Propósito: Etapa final do onboarding, exibe as metas diárias calculadas organizadas por categoria
//             e permite ao usuário adicionar opcionalmente Gordura, Creatina e Vitamina D antes de concluir.
//             Os parágrafos informativos aparecem no fim, depois das metas opcionais.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-10.
// ⌘

import SwiftUI
import GymNutshellCore

/// Última etapa do onboarding: mostra as metas organizadas por categoria.
/// Fixas aparecem como linhas informativas; opcionais têm botão Adicionar/Remover.
struct WelcomeSummaryStep: View {

    let goals: GoalsCalculator.Result?
    let measurementSystem: MeasurementSystem
    let userGoal: UserGoal
    let accentColor: Color
    @Binding var includeFats: Bool
    @Binding var includeCreatine: Bool
    @Binding var includeVitaminD: Bool
    @Binding var scrolledToEnd: Bool
    var isWide: Bool = false

    private var goalColor: Color {
        switch userGoal {
        case .bulking:     return .orange
        case .maintenance: return .blue
        case .cutting:     return .green
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {

                if !isWide {
                    WelcomeStepHeader(
                        emoji: "✅",
                        title: String(localized: "welcome.step.summary.title", bundle: .gymNutshellCore),
                        subtitle: String(localized: "welcome.step.summary.subtitle", bundle: .gymNutshellCore)
                    )
                }

                if let goals {

                    // MARK: Essencial
                    summaryCategory(GoalCategory.essencial) {
                        summaryRow(icon: "💤", label: String(localized: "today.metric.sleep", bundle: .gymNutshellCore),
                                   value: "\(goals.sleep)h")
                        summaryRow(icon: "💧", label: String(localized: "today.metric.water", bundle: .gymNutshellCore),
                                   value: measurementSystem == .us
                                       ? "\(Int(UnitConverter.mlToFlOz(Double(goals.water)).rounded())) fl oz"
                                       : "\(goals.water) ml")
                    }

                    // MARK: Treino
                    summaryCategory(GoalCategory.treino) {
                        summaryRow(icon: "🏋️", label: String(localized: "today.goals.workout", bundle: .gymNutshellCore),
                                   value: "\(goals.workout) min")
                        summaryRow(icon: "🏃", label: String(localized: "today.goals.cardio", bundle: .gymNutshellCore),
                                   value: "\(goals.cardio) min")
                    }

                    // MARK: Nutrição
                    summaryCategory(GoalCategory.nutricao) {
                        summaryRow(icon: "🍗", label: String(localized: "today.metric.protein", bundle: .gymNutshellCore),
                                   value: "\(goals.protein)g")
                        summaryRow(icon: "🌾", label: String(localized: "today.metric.fiber", bundle: .gymNutshellCore),
                                   value: "\(goals.fiber)g")
                        summaryRow(icon: "🍞", label: String(localized: "today.metric.carbs", bundle: .gymNutshellCore),
                                   value: "\(goals.carbs)g")
                        OptionalTrackingGoalRow(
                            icon: "🧈",
                            label: String(localized: "today.metric.fats", bundle: .gymNutshellCore),
                            value: "\(goals.goodFat)g",
                            accentColor: accentColor,
                            isIncluded: $includeFats
                        )
                    }

                    // MARK: Suplemento
                    summaryCategory(GoalCategory.suplemento) {
                        OptionalTrackingGoalRow(
                            icon: "🧪",
                            label: String(localized: "today.goals.creatine", bundle: .gymNutshellCore),
                            value: "\(goals.creatine)g",
                            accentColor: accentColor,
                            isIncluded: $includeCreatine
                        )
                    }

                    // MARK: Vitamina
                    summaryCategory(GoalCategory.vitamina) {
                        OptionalTrackingGoalRow(
                            icon: "☀️",
                            label: String(localized: "today.goals.vitaminD", bundle: .gymNutshellCore),
                            value: "\(DefaultGoals.vitaminD) min",
                            accentColor: accentColor,
                            isIncluded: $includeVitaminD
                        )
                    }

                    // Rodapé informativo, centralizado para alinhar com as metas.
                    // Sentinela de scroll fica dentro do VStack pra reduzir o espaçamento após a creatina.
                    VStack(alignment: .center, spacing: 10) {
                        Color.clear.frame(height: 1)
                            .onAppear { scrolledToEnd = true }

                        (Text(String(localized: "welcome.summary.subtitle.calculated.prefix", bundle: .gymNutshellCore))
                         + Text(userGoal.label).fontWeight(.semibold)
                         + Text(String(localized: "welcome.summary.subtitle.calculated.suffix", bundle: .gymNutshellCore)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(String(localized: "welcome.summary.subtitle.customize", bundle: .gymNutshellCore))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, -10)
                }
            }
            .padding()
        }
    }

    // MARK: - Seção de categoria (não colapsável no onboarding)

    private func summaryCategory<Content: View>(
        _ category: GoalCategory,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            content()
        }
    }

    // MARK: - Linha de meta fixa (obrigatória)

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Text(icon)
                .accessibilityHidden(true)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}

// MARK: - Linha de meta de rastreio opcional

private struct OptionalTrackingGoalRow: View {

    let icon: String
    let label: String
    let value: String
    let accentColor: Color
    @Binding var isIncluded: Bool

    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        HStack {
            // Bloco informativo (emoji + nome + badge + valor) combina num único
            // elemento de a11y; botão Add/Remove fica FORA do combine pra ser
            // focável separadamente (mesmo padrão do TrackingGoalRow do Today).
            HStack {
                Text(icon)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline)
                    Text(String(localized: "welcome.summary.optional.badge", bundle: .gymNutshellCore))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(Capsule())
                }
                Spacer()
                Text(value)
                    .font(isIncluded ? .subheadline.bold() : .subheadline)
                    .foregroundStyle(.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityValue(value)

            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                    buttonScale = 1.4
                }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5).delay(0.12)) {
                    buttonScale = 1.0
                }
                isIncluded.toggle()
            } label: {
                Text(isIncluded
                     ? String(localized: "welcome.option.remove", bundle: .gymNutshellCore)
                     : String(localized: "welcome.option.add", bundle: .gymNutshellCore))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isIncluded ? .red : accentColor)
                    .scaleEffect(buttonScale)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(format: String(localized: isIncluded
                ? "a11y.welcome.optional.remove.label.format"
                : "a11y.welcome.optional.add.label.format", bundle: .gymNutshellCore), label))
            .accessibilityHint(String(localized: isIncluded
                ? "a11y.welcome.optional.remove.hint"
                : "a11y.welcome.optional.add.hint", bundle: .gymNutshellCore))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
