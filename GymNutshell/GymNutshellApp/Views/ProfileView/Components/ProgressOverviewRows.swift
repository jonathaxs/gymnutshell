// ⌘
//  GymNutshell/GymNutshellApp/Views/ProfileView/Components/ProgressOverviewRows.swift
//
//  Propósito: Linhas reutilizáveis dos cards da ProgressOverView, tier, bônus,
//             atividade e metas ativas. Cada linha encapsula label visual + a11y.
// ⌘

import SwiftUI
import GymNutshellCore

/// Linha de tier: emoji do mascote + nome + total de dias.
struct TierRow: View {
    let emoji: String
    let label: String
    let days: Int

    var body: some View {
        HStack {
            Text(emoji)
                .accessibilityHidden(true)
            Text(label)
            Spacer()
            Text(String(format: String(localized: "statistics.tier.days", bundle: .gymNutshellCore), days))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.stats.tier.row.format",
                                                 bundle: .gymNutshellCore), label, days))
    }
}

/// Linha de bônus de sequência, toda a linha é tappável e abre a sheet informativa.
struct BonusRow: View {
    let label: String
    let count: Int
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(String(format: String(localized: "statistics.bonus.times", bundle: .gymNutshellCore), count))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .tapButton(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.stats.bonus.row.format",
                                                 bundle: .gymNutshellCore), label, count))
        .accessibilityHint(String(localized: "a11y.record.bonus.hint", bundle: .gymNutshellCore))
    }
}

/// Linha de atividade (treino/cardio), emoji + nome + total de dias.
struct ActivityRow: View {
    let emoji: String
    let label: String
    let days: Int

    var body: some View {
        HStack {
            Text(emoji)
                .accessibilityHidden(true)
            Text(label)
            Spacer()
            Text(String(format: String(localized: "statistics.tier.days", bundle: .gymNutshellCore), days))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.stats.activity.row.format",
                                                 bundle: .gymNutshellCore), label, days))
    }
}

/// Linha de metas ativas, emoji fixo ✅ + label + contagem.
struct GoalsRow: View {
    let label: String
    let count: Int

    var body: some View {
        HStack {
            Text("✅")
                .accessibilityHidden(true)
            Text(label)
            Spacer()
            Text(String(format: String(localized: "statistics.goals.active", bundle: .gymNutshellCore), count))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.stats.goals.row.format",
                                                 bundle: .gymNutshellCore), label, count))
    }
}
