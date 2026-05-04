// ⌘
//  GymNutshellWatch/WatchRootView.swift
//
//  Propósito: Container de navegação por página do Watch app.
//             Ordem: Stats ← Today → Notifications
//             Today (índice 1) é a página padrão ao abrir.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-29.
// ⌘

import SwiftUI

struct WatchRootView: View {

    @State private var selectedPage: Int = 1

    var body: some View {
        TabView(selection: $selectedPage) {
            WatchStatsView()
                .tag(0)

            ContentView()
                .tag(1)

            WatchNotificationsView()
                .tag(2)
        }
        .tabViewStyle(.page)
    }
}
