// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Preferences/ColorSettingsView.swift
//
//  Propósito: Permite ao usuário escolher a cor de destaque do app independentemente do sexo.
//             O padrão é definido no onboarding com base no sexo, mas pode ser alterado livremente aqui.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-15.
// ⌘

import SwiftUI
import GymNutshellCore

struct ColorSettingsView: View {

    @AppStorage(AppAccentColor.storageKey) private var selectedColorRaw: String = AppAccentColor.blue.rawValue

    private var selectedColor: AppAccentColor {
        AppAccentColor(rawValue: selectedColorRaw) ?? .blue
    }

    // Grade 4 colunas — exibe todas as 8 cores com nome e checkmark.
    private let columns = [GridItem(.flexible()), GridItem(.flexible()),
                           GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        List {
            Section(String(localized: "settings.color.subtitle", bundle: .gymNutshellCore)) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(AppAccentColor.allCases, id: \.self) { accent in
                        Button {
                            selectedColorRaw = accent.rawValue
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(accent.color)
                                        .frame(width: 52, height: 52)

                                    if selectedColor == accent {
                                        Image(systemName: "checkmark")
                                            .font(.body.weight(.bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedColor == accent ? accent.color : Color.clear,
                                            lineWidth: 2.5
                                        )
                                        .padding(-4)
                                )

                                Text(accent.displayName)
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(String(localized: "settings.color.title", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
    }
}
