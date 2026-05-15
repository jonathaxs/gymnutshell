// ⌘
//  GymNutshell/GymNutshellApp/Views/Shared/AchievementStyles.swift
//
//  Propósito: Extensão da camada de apresentação pro DailyAchievement.
//             Mantém valores de cor do SwiftUI fora da camada de modelo.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-28.
// ⌘

import SwiftUI
import GymNutshellCore

// MARK: - DailyAchievement + Cor

extension DailyAchievement {

    // Cor representativa associada ao nível de conquista.
    // Usada principalmente pra fundos sutis e destaques.
    var color: Color {
        switch self {
        case .level1:
            return Color.red.opacity(0.30)
        case .level2:
            return Color.yellow.opacity(0.30)
        case .level3:
            return Color.green.opacity(0.30)
        case .level4:
            return Color.blue.opacity(0.30)
        }
    }
}
