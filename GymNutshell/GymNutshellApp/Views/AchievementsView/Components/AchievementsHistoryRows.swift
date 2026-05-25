// ⌘
//  GymNutshell/GymNutshellApp/Views/AchievementsView/Components/AchievementsHistoryRows.swift
//
//  Propósito: Linhas da lista de histórico em Conquistas, uma para registros
//             diários (com botão de editar quando dentro da janela) e outra para
//             bônus de sequência.
// ⌘

import SwiftUI
import GymNutshellCore

/// Linha da lista que representa um `DailyRecord`. O HStack interno é o alvo
/// tappável e cabe num único elemento de VoiceOver; o botão de editar fica
/// fora pra ser focado separadamente.
struct HistoryDailyRow: View {
    let record: DailyRecord
    let tierName: String
    let tierEmoji: String
    let canEdit: Bool
    let onTap: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 16) {
                Text(tierEmoji)
                    .font(.largeTitle)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(tierName)
                        .font(.headline)

                    Text(String(format: String(localized: "achievements.daily.row.description",
                                              bundle: .gymNutshellCore), record.percent))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(record.date, style: .date)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }

                Spacer()

                Text("\(record.points) \(String(localized: "achievements.points.total", bundle: .gymNutshellCore))")
                    .font(.subheadline.bold())
            }
            .contentShape(Rectangle())
            .tapButton(perform: onTap)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(String(format: String(localized: "a11y.record.row.daily.format",
                                                     bundle: .gymNutshellCore),
                                       tierName,
                                       A11y.spokenDate(for: record.date),
                                       record.percent, record.points))
            .accessibilityHint(String(localized: "a11y.record.row.hint", bundle: .gymNutshellCore))

            // Botão de edição, visível só pra registros dentro da janela editável.
            if canEdit {
                Button(action: onEdit) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18, weight: .regular))
                }
                .buttonStyle(.borderless)
                .pressScale(1.20, response: 0.25, dampingFraction: 0.50)
                .accessibilityLabel(String(localized: "a11y.record.edit.label", bundle: .gymNutshellCore))
                .accessibilityHint(String(localized: "a11y.record.edit.hint", bundle: .gymNutshellCore))
            }
        }
        .padding(.vertical, 8)
    }
}

/// Linha da lista que representa um `StreakBonus`. O "+" no total diferencia
/// pontos de bônus dos pontos diários.
struct HistoryBonusRow: View {
    let bonus: StreakBonus
    let onTap: () -> Void

    var body: some View {
        let bTitle = bonus.displayTitle
        let bDesc  = bonus.displayDescription
        HStack(spacing: 16) {
            Text(bonus.displayEmoji)
                .font(.largeTitle)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(bTitle)
                    .font(.headline)

                Text(bDesc)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(bonus.anchorDate, style: .date)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }

            Spacer()

            Text("+\(bonus.bonusPoints) \(String(localized: "achievements.points.total", bundle: .gymNutshellCore))")
                .font(.subheadline.bold())
                .foregroundStyle(Color.accentColor)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .tapButton(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.record.row.bonus.format",
                                                 bundle: .gymNutshellCore),
                                   bTitle, bDesc, bonus.bonusPoints))
        .accessibilityHint(String(localized: "a11y.record.bonus.hint", bundle: .gymNutshellCore))
    }
}
