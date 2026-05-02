// ⌘
//  GymNutshellCore/Stores/GoalCategoryOrderStore.swift
//
//  Propósito: Persiste a ordem de exibição das categorias de metas definida pelo usuário.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-15.
// ⌘

import Foundation

public enum GoalCategoryOrderStore {

    public static let defaultOrder: [GoalCategory] = GoalCategory.allCases

    private static let key = "goal.category.order"

    public static func load() -> [GoalCategory] {
        guard let stored = UserDefaults.standard.array(forKey: key) as? [String] else {
            return defaultOrder
        }
        let ordered = stored.compactMap { GoalCategory(rawValue: $0) }
        guard Set(ordered.map(\.rawValue)) == Set(defaultOrder.map(\.rawValue)) else {
            return defaultOrder
        }
        return ordered
    }

    public static func save(_ order: [GoalCategory]) {
        UserDefaults.standard.set(order.map(\.rawValue), forKey: key)
    }
}
