// ⌘
//  GymNutshell/GymNutshellApp/Views/AchievementsView/TrackingGoalRow.swift
//
//  Propósito: Versão somente leitura do TrackingGoalRow, usada pra exibir registros históricos.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-01-29.
// ⌘

import SwiftUI
import GymNutshellCore

struct TrackingGoalRow: View {

    // MARK: - Entradas
    let icon: String
    let title: String
    let unit: String
    let goal: Int
    let value: Int

    // MARK: - Valores computados
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(value) / Double(goal), 1.0)
    }

    // Resumo legível da métrica em relação à meta
    private var metricText: String {
        "\(value) \(unit) / \(goal) \(unit)"
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(icon)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.headline)

                Spacer()

                Text(metricText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Representação visual do progresso pra inspeção histórica.
            // Oculto do a11y, o value composto abaixo já comunica X de Y completed.
            ProgressView(value: Double(value), total: Double(goal))
                .tint(Color.accentColor)
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .frame(height: 10)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .accessibilityHidden(true)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.goalrow.a11y.label",
                                                 bundle: .gymNutshellCore), title))
        .accessibilityValue(A11y.goalRowValue(current: value, goal: goal, unit: unit))
    }
}

#Preview {
    TrackingGoalRow(
        icon: "🍗",
        title: "Protein",
        unit: "g",
        goal: 150,
        value: 120
    )
}
