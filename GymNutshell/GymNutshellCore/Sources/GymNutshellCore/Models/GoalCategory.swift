// ⌘
//  GymNutshellCore/Models/GoalCategory.swift
//
//  Propósito: Define as cinco categorias usadas pra agrupar metas fixas e personalizadas.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-14.
// ⌘

import Foundation

/// Categorias usadas pra agrupar as metas de rastreio fixas e personalizadas.
/// A ordem dos cases define a ordem de exibição nas telas (Essencial primeiro).
public enum GoalCategory: String, Codable, CaseIterable, Sendable {

    case essencial
    case nutricao
    case treino
    case suplemento
    case vitamina

    // MARK: - Nome localizado

    public var displayName: String {
        switch self {
        case .essencial:  return String(localized: "goal.category.essencial", bundle: .gymNutshellCore)
        case .nutricao:   return String(localized: "goal.category.nutricao", bundle: .gymNutshellCore)
        case .treino:     return String(localized: "goal.category.treino", bundle: .gymNutshellCore)
        case .vitamina:   return String(localized: "goal.category.vitamina", bundle: .gymNutshellCore)
        case .suplemento: return String(localized: "goal.category.suplemento", bundle: .gymNutshellCore)
        }
    }

    // MARK: - Mapeamento de chaves fixas

    /// Categoria padrão de uma chave de meta fixa (ignora o modo VitaminD).
    public static func defaultCategory(for key: String) -> GoalCategory? {
        switch key {
        case "tracking.sleep", "tracking.water":
            return .essencial
        case "tracking.protein", "tracking.carbs", "tracking.goodFat", "tracking.fiber":
            return .nutricao
        case "tracking.workout", "tracking.cardio":
            return .treino
        case "tracking.vitaminD":
            return .vitamina
        case "tracking.creatine":
            return .suplemento
        default:
            return nil
        }
    }

    /// Categoria efetiva de uma chave de meta, respeitando o modo VitaminD atual.
    public static func effectiveCategory(for key: String, vitaminDCategory: GoalCategory) -> GoalCategory? {
        if key == "tracking.vitaminD" { return vitaminDCategory }
        return defaultCategory(for: key)
    }

    // MARK: - Persistência do modo VitaminD

    public static let vitaminDCategoryKey = "tracking.vitaminD.category"

    // MARK: - Helpers do modo VitaminD

    public static func vitaminDUnit(for category: GoalCategory) -> String {
        category == .suplemento ? "UI" : "min"
    }

    public static func vitaminDFallback(for category: GoalCategory) -> Int {
        category == .suplemento ? 2000 : DefaultGoals.vitaminD
    }

    public static func vitaminDIncrement(for category: GoalCategory) -> Int {
        category == .suplemento ? 500 : DefaultGoals.vitaminDIncrement
    }
}
