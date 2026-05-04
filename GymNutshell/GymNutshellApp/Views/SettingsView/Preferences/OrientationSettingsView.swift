// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Preferences/OrientationSettingsView.swift
//
//  Propósito: Permite ao usuário travar a orientação do app em retrato
//             ou aceitar ambas. Tap aplica imediato via OrientationLockManager —
//             sem botão de Salvar, mesmo padrão do MeasurementSettingsView.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-25.
// ⌘

import SwiftUI
import GymNutshellCore

/// Tela de settings pra escolher o travamento de orientação do app.
struct OrientationSettingsView: View {

    @ObservedObject private var manager = OrientationLockManager.shared

    var body: some View {
        List {
            Section {
                row(.portrait, label: String(localized: "settings.orientation.portrait", bundle: .gymNutshellCore))
                row(.both, label: String(localized: "settings.orientation.both", bundle: .gymNutshellCore))
            } footer: {
                Text(String(localized: "settings.orientation.footer", bundle: .gymNutshellCore))
            }
        }
        .navigationTitle(String(localized: "settings.preference.orientation", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func row(_ orientation: AppOrientation, label: String) -> some View {
        Button {
            manager.set(orientation)
        } label: {
            HStack {
                Text(label)
                Spacer()
                if manager.current == orientation {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(.primary)
        }
    }
}
