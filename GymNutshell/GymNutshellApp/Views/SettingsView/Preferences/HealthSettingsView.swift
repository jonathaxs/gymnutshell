// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Preferences/HealthSettingsView.swift
//
//  Propósito: Página dedicada pras configurações de integração com o Apple Health.
//             Agrupa os toggles de sync de sono e auto check-in de treino.
//             A autorização é solicitada quando o usuário ativa cada funcionalidade.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-25.
// ⌘

import SwiftUI
import GymNutshellCore

/// Página de settings pras integrações com o Apple Health (sync de sono e auto check-in de treino).
/// Cada toggle solicita a autorização do HealthKit quando ativado.
struct HealthSettingsView: View {

    @AppStorage("healthkit.syncSleepEnabled") private var syncSleepToAppleHealth: Bool = false
    @AppStorage("healthkit.autoWorkoutCheckin") private var autoWorkoutCheckin: Bool = false

    var body: some View {
        List {
            Section {
                Toggle(String(localized: "settings.preference.appleHealth.syncSleep", bundle: .gymNutshellCore),
                       isOn: $syncSleepToAppleHealth)
                Toggle(String(localized: "settings.preference.appleHealth.autoWorkoutCheckin", bundle: .gymNutshellCore),
                       isOn: $autoWorkoutCheckin)
            } footer: {
                Text(String(localized: "settings.preference.appleHealth.footer", bundle: .gymNutshellCore))
            }
        }
        .navigationTitle(String(localized: "settings.preference.appleHealth", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: syncSleepToAppleHealth) { _, newValue in
            if newValue {
                HealthKitManager.shared.requestSleepAuthorizationIfNeeded()
            }
        }
        .onChange(of: autoWorkoutCheckin) { _, newValue in
            if newValue {
                HealthKitManager.shared.requestWorkoutReadAuthorizationIfNeeded()
            }
        }
    }
}
