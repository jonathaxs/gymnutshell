// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Preferences/ThemeInfoView.swift
//
//  Propósito: Sheet informativo exibido quando o usuário toca no botão (i) ao lado de um tema.
//             Mostra os quatro emojis de nível e os nomes localizados pra aquele tema.
//             Sempre apresentado como sheet (nunca via NavigationLink).
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-18.
// ⌘

import SwiftUI
import GymNutshellCore

/// Exibe os quatro níveis de conquista de um tema específico:
/// emoji, nome localizado (respeitando gênero) e faixa de porcentagem.
struct ThemeInfoView: View {

    let theme: AppTheme
    let sex: String
    // Permite sobrescrever a cor de destaque (usado no fluxo Welcome, antes do usuário salvar a escolha).
    var accentOverride: Color? = nil

    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color {
        accentOverride ?? (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color
    }

    private let tiers: [DailyAchievement] = DailyAchievement.allCases

    private func rangeLabel(for tier: DailyAchievement) -> String {
        let range: String
        switch tier {
        case .level1: range = "0 – 49%"
        case .level2: range = "50 – 69%"
        case .level3: range = "70 – 89%"
        case .level4: range = "90 – 100%"
        }
        return range + String(localized: "tier.info.range.suffix", bundle: .gymNutshellCore)
    }

    private func tierLevel(for tier: DailyAchievement) -> Int {
        switch tier {
        case .level1: return 1
        case .level2: return 2
        case .level3: return 3
        case .level4: return 4
        }
    }

    var body: some View {
        List {
            Section(String(localized: "tier.info.section.levels", bundle: .gymNutshellCore)) {
                ForEach(tiers, id: \.self) { tier in
                    HStack(spacing: 14) {
                        Text(theme.emoji(for: tier, sex: sex))
                            .font(.title2)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(theme.name(for: tier, sex: sex))
                                .font(.subheadline.weight(.semibold))
                            Text(rangeLabel(for: tier))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(String(localized: "ring.info.level.label", bundle: .gymNutshellCore) + "\(tierLevel(for: tier))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .navigationTitle(theme.displayName(sex: sex))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "welcome.button.back", bundle: .gymNutshellCore))
                        .foregroundStyle(accentColor)
                }
            }
        }
    }
}
