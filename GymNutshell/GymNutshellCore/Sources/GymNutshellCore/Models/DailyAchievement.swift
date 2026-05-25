// ⌘
//  GymNutshellCore/Models/DailyAchievement.swift
//
//  Propósito: Define a lógica dos níveis de conquista diária (emoji, nome, cor, pontos) com base no progresso.
//
//  Created by Jonathas Motta (@jonathaxs) on 2025-11-22.
// ⌘

import Foundation

// MARK: - DailyAchievement (Enum dos níveis de conquista diária)
public enum DailyAchievement: CaseIterable, Sendable {
    case level1
    case level2
    case level3
    case level4
}

extension DailyAchievement {
    /// Converte um valor de progresso normalizado (0...1) no tier `DailyAchievement` correspondente.
    public static func from(progress: Double) -> DailyAchievement {
        switch progress {
        case ..<0.33:
            return .level1
        case ..<0.66:
            return .level2
        case ..<0.9:
            return .level3
        default:
            return .level4
        }
    }

    /// Converte um emoji armazenado (vindo de `DailyRecord`) de volta pro tier `DailyAchievement`.
    public static func from(emoji: String) -> DailyAchievement {
        for theme in AppTheme.allCases {
            for tier in DailyAchievement.allCases {
                if theme.emoji(for: tier) == emoji {
                    return tier
                }
            }
        }
        return .level1
    }

    // MARK: - Propriedades de exibição

    public var emoji: String {
        switch self {
        case .level1:
            return "🐱"
        case .level2:
            return "🐈"
        case .level3:
            return "🐆"
        case .level4:
            return "🦁"
        }
    }

    public var name: String {
        switch self {
        case .level1:
            return String(localized: "daily.achievement.level1", bundle: .gymNutshellCore)
        case .level2:
            return String(localized: "daily.achievement.level2", bundle: .gymNutshellCore)
        case .level3:
            return String(localized: "daily.achievement.level3", bundle: .gymNutshellCore)
        case .level4:
            return String(localized: "daily.achievement.level4", bundle: .gymNutshellCore)
        }
    }

    public var points: Int {
        switch self {
        case .level1:
            return 0
        case .level2:
            return 40
        case .level3:
            return 60
        case .level4:
            return 90
        }
    }
}
