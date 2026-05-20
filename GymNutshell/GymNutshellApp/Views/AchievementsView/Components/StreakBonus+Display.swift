// ⌘
//  GymNutshell/GymNutshellApp/Views/AchievementsView/Components/StreakBonus+Display.swift
//
//  Propósito: Mapeamentos de `bonusType` (string persistida) pra emoji/título/
//             descrição localizados, usados na lista de histórico e no calendário.
// ⌘

import Foundation
import GymNutshellCore

extension StreakBonus {
    /// Emoji exibido na lista e no calendário pra este bônus. Reflete o emoji
    /// vigente do app, evitando mostrar emojis antigos persistidos.
    var displayEmoji: String { BonusDisplay.emoji(for: bonusType) }

    /// Título localizado pra esta linha de bônus.
    var displayTitle: String { BonusDisplay.title(for: bonusType) }

    /// Descrição localizada explicando por que o bônus foi ganho.
    var displayDescription: String { BonusDisplay.description(for: bonusType) }
}

/// Lookup compartilhado pra quando o `StreakBonus` ainda não está disponível
/// (ex.: ao trabalhar com `bonusType: String` solto durante construção de maps).
enum BonusDisplay {
    static func emoji(for bonusType: String) -> String {
        switch bonusType {
        case "weekly.level3":  return "🎖️"
        case "weekly.level4":  return "💀"
        case "monthly.level3": return "🏆"
        case "monthly.level4": return "☠️"
        default:               return "🏅"
        }
    }

    static func title(for bonusType: String) -> String {
        switch bonusType {
        case "weekly.level3":  return String(localized: "streak.bonus.weekly.level3.title",  bundle: .gymNutshellCore)
        case "weekly.level4":  return String(localized: "streak.bonus.weekly.level4.title",  bundle: .gymNutshellCore)
        case "monthly.level3": return String(localized: "streak.bonus.monthly.level3.title", bundle: .gymNutshellCore)
        case "monthly.level4": return String(localized: "streak.bonus.monthly.level4.title", bundle: .gymNutshellCore)
        default:               return String(localized: "streak.bonus.generic.title",        bundle: .gymNutshellCore)
        }
    }

    static func description(for bonusType: String) -> String {
        switch bonusType {
        case "weekly.level3":  return String(localized: "streak.bonus.weekly.level3.description",  bundle: .gymNutshellCore)
        case "weekly.level4":  return String(localized: "streak.bonus.weekly.level4.description",  bundle: .gymNutshellCore)
        case "monthly.level3": return String(localized: "streak.bonus.monthly.level3.description", bundle: .gymNutshellCore)
        case "monthly.level4": return String(localized: "streak.bonus.monthly.level4.description", bundle: .gymNutshellCore)
        default:               return ""
        }
    }
}
