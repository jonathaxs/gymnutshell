// ⌘
//  GymNutshellWatch/DailyAchievement+Color.swift
//
//  Propósito: Camada SwiftUI do DailyAchievement no Watch, mapeia o tier
//             pra uma cor representativa (mesma escala do iPhone).
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-26.
// ⌘

import SwiftUI
import GymNutshellCore

extension DailyAchievement {
    /// Cor base associada ao nível de conquista (sem opacidade).
    var color: Color {
        switch self {
        case .level1: return .red
        case .level2: return .yellow
        case .level3: return .green
        case .level4: return .blue
        }
    }
}
