// ⌘
//  GymNutshell/GymNutshellApp/Views/ProfileView/Components/ProfileStatsRow.swift
//
//  Propósito: Linha com três cards de estatística — total de dias, total de pontos e contagem de bônus.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-28.
// ⌘

import SwiftUI
import GymNutshellCore

/// Três cards de estatísticas lado a lado mostrando o resumo de atividade do usuário.
struct ProfileStatsRow: View {

    let totalDays: Int
    let totalPoints: Int
    let bonusCount: Int

    // Dias → calendário de hoje; Bônus → sheet de bônus de sequência.
    var onDaysTap: (() -> Void)? = nil
    var onBonusTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            cardBase(value: "\(totalDays)", label: String(localized: "profile.stats.days", bundle: .gymNutshellCore))
                .contentShape(Rectangle())
                .onTapGesture { onDaysTap?() }

            // Pontos mantém o efeito de escala; Dias e Bônus não.
            cardBase(value: "\(totalPoints)", label: String(localized: "profile.stats.points", bundle: .gymNutshellCore))
                .pressScale(1.20, response: 0.25, dampingFraction: 0.50)

            cardBase(value: "\(bonusCount)", label: String(localized: "profile.stats.bonuses", bundle: .gymNutshellCore))
                .contentShape(Rectangle())
                .onTapGesture { onBonusTap?() }
        }
    }

    private func cardBase(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: .infinity))
    }
}
