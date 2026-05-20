// ⌘
//  GymNutshell/GymNutshellApp/Views/AchievementsView/Components/AchievementsEmptyState.swift
//
//  Propósito: Card de estado vazio da Conquistas — ícone na cor de destaque
//             do usuário e texto sem truncação.
// ⌘

import SwiftUI
import GymNutshellCore

struct AchievementsEmptyState: View {
    let accentColor: Color

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 40))
                .foregroundStyle(accentColor)
            Text(String(localized: "achievements.empty.title", bundle: .gymNutshellCore))
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(String(localized: "achievements.empty.description", bundle: .gymNutshellCore))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
    }
}
