// ⌘
//  GymNutshell/GymNutshellApp/Views/TodayView/Components/StreakBonusInfoView.swift
//
//  Propósito: View informativa sobre o sistema de bônus de sequência.
//             Exibida como sheet quando o usuário toca num bônus na AchievementsView
//             ou StatisticsView e também acessível em Configurações > Sobre > Bônus de Sequência.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-18.
// ⌘

import SwiftUI
import GymNutshellCore

/// Exibe uma explicação dos quatro tipos de bônus de sequência:
/// emoji, nome, condição de desbloqueio e pontos concedidos.
struct StreakBonusInfoView: View {

    var isSheet: Bool = false

    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color { (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color }

    private struct BonusInfo: Identifiable {
        let emoji: String
        let id: String
        let titleKey: String
        let descKey: String
        let points: Int
    }

    private let bonuses: [BonusInfo] = [
        BonusInfo(emoji: "🎖️", id: "weekly.level3",  titleKey: "streak.bonus.weekly.level3.title",  descKey: "streak.bonus.weekly.level3.description",  points: 400),
        BonusInfo(emoji: "💀", id: "weekly.level4",  titleKey: "streak.bonus.weekly.level4.title",  descKey: "streak.bonus.weekly.level4.description",  points: 800),
        BonusInfo(emoji: "🏆", id: "monthly.level3", titleKey: "streak.bonus.monthly.level3.title", descKey: "streak.bonus.monthly.level3.description", points: 2000),
        BonusInfo(emoji: "☠️", id: "monthly.level4", titleKey: "streak.bonus.monthly.level4.title", descKey: "streak.bonus.monthly.level4.description", points: 5000),
    ]

    var body: some View {
        List {
            Section {
                Text(String(localized: "streak.bonus.info.intro", bundle: .gymNutshellCore))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }
            .listRowBackground(Color.clear)

            Section(String(localized: "statistics.section.bonuses", bundle: .gymNutshellCore)) {
                ForEach(bonuses) { bonus in
                    let title = String(localized: String.LocalizationValue(bonus.titleKey), bundle: .gymNutshellCore)
                    let desc  = String(localized: String.LocalizationValue(bonus.descKey),  bundle: .gymNutshellCore)
                    HStack(spacing: 14) {
                        Text(bonus.emoji)
                            .font(.title2)
                            .frame(width: 36)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.subheadline.weight(.semibold))
                            Text(desc)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("+\(bonus.points) pts")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(String(format: String(localized: "a11y.bonusinfo.row.format",
                                                             bundle: .gymNutshellCore),
                                               title, desc, bonus.points))
                }
            }
        }
        .navigationTitle(String(localized: "statistics.section.bonuses", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isSheet {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(String(localized: "common.close", bundle: .gymNutshellCore))
                            .foregroundStyle(accentColor)
                    }
                }
            }
        }
    }
}
