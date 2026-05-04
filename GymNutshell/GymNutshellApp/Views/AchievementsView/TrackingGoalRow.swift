// ⌘
//  GymNutshell/GymNutshellApp/Views/AchievementsView/TrackingGoalRow.swift
//
//  Propósito: Versão somente leitura do TrackingGoalRow, usada pra exibir registros históricos.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-01-29.
// ⌘

import SwiftUI

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
                Text(title)
                    .font(.headline)

                Spacer()

                Text(metricText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Representação visual do progresso pra inspeção histórica
            ProgressView(value: Double(value), total: Double(goal))
                .tint(Color.accentColor)
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .frame(height: 10)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }
        .padding(.vertical, 6)
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
