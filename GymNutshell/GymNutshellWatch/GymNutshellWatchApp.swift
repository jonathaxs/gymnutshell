// ⌘
//  GymNutshellWatch/GymNutshellWatchApp.swift
//
//  Propósito: Entry point do Watch app. Ativa o WCSession cedo pra receber o
//             snapshot do iPhone assim que disponível.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-25.
// ⌘

import SwiftUI
import GymNutshellCore
import WidgetKit

@main
struct GymNutshellWatchApp: App {

    init() {
        // Aplica o idioma sincronizado do iPhone antes do SwiftUI inicializar qualquer view.
        // "AppleLanguages" só é lido pelo sistema de localização na inicialização do processo,
        // por isso precisa ser definido aqui, não em onAppear ou similar.
        if let lang = UserDefaults.standard.string(forKey: "app.preferredLanguage") {
            UserDefaults.standard.set([lang], forKey: "AppleLanguages")
        }

        WatchConnectivityManager.shared.activate()
        // Quando chega snapshot novo do iPhone com o app aberto, recarrega imediatamente.
        NotificationCenter.default.addObserver(
            forName: .gymNutshellWatchWidgetReload,
            object: nil,
            queue: .main
        ) { _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    var body: some Scene {
        WindowGroup {
            WatchRootView()
        }
        // Quando o sistema acorda o Watch app em background por dados novos do WatchConnectivity,
        // recarrega as complications sem que o usuário precise abrir o app.
        .backgroundTask(.watchConnectivity) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
