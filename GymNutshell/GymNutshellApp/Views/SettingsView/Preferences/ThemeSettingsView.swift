// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Preferences/ThemeSettingsView.swift
//
//  Propósito: Permite ao usuário escolher o tema do mascote (ex: Gato, Cachorro, Urso...).
//             Cada tema troca os emojis e os nomes dos níveis em todo o app.
//             Os temas são agrupados por categoria pra facilitar a navegação.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-28.
// ⌘

import SwiftUI
import GymNutshellCore

// MARK: - Tela de tema

struct ThemeSettingsView: View {

    @AppStorage(AppTheme.storageKey) private var selectedTheme: AppTheme = .gym
    @AppStorage(UserProfile.sexKey) private var sex: String = "male"
    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color { (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color }

    @State private var infoTheme: AppTheme? = nil

    var body: some View {
        List {
            ForEach(AppTheme.ThemeCategory.allCases, id: \.self) { category in
                Section(category.localizedName(sex: sex)) {
                    ForEach(AppTheme.themes(in: category), id: \.self) { theme in
                        let isSelected = selectedTheme == theme
                        HStack {
                            // Prévia dos quatro emojis de nível pra esse tema.
                            Text(theme.themeEmojis(sex: sex))
                                .font(.title3)

                            Text(theme.displayName(sex: sex))
                                .foregroundColor(isSelected ? .white : Color.primary)

                            Spacer()

                            Button {
                                infoTheme = theme
                            } label: {
                                Image(systemName: "info.circle")
                            }
                            .buttonStyle(.borderless)
                            .tint(isSelected ? .white : .accentColor)

                            // Checkmark no tema atualmente ativo.
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.subheadline.weight(.bold))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTheme = theme
                        }
                        .listRowBackground(isSelected ? accentColor : nil)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "settings.theme.title", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $infoTheme) { theme in
            NavigationStack {
                ThemeInfoView(theme: theme, sex: sex)
            }
        }
    }
}
