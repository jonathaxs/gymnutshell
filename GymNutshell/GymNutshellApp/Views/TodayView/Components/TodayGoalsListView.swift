// ⌘
//  GymNutshell/GymNutshellApp/Views/TodayView/Components/TodayGoalsListView.swift
//
//  Propósito: Container estrutural pra lista de metas, limita o conteúdo à largura
//             máxima do design (330 pt) e centraliza horizontalmente.
//             Usado tanto no layout retrato quanto no layout wide da TodayView.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-29.
// ⌘

import SwiftUI

/// Wrapper centralizado com largura máxima pras linhas de metas da TodayView.
struct TodayGoalsListView<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 10) {
            content
        }
        .padding(.top, 12)
        .padding(.bottom, 16)
        .frame(maxWidth: 330)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
