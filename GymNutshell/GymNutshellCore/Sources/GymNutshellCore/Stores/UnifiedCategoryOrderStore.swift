// ⌘
//  GymNutshellCore/Stores/UnifiedCategoryOrderStore.swift
//
//  Propósito: Persiste uma ordem única que mistura os cases fixos de GoalCategory e
//             entradas CustomGoalCategory criadas pelo usuário.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-20.
// ⌘

import Foundation

/// Item de categoria, pode ser uma categoria fixa do app ou uma criada pelo usuário.
public enum CategoryItem: Hashable, Identifiable, Sendable {
    case builtin(GoalCategory)
    case custom(CustomGoalCategory)

    public var id: String {
        switch self {
        case .builtin(let c): return "builtin:\(c.rawValue)"
        case .custom(let c):  return "custom:\(c.id)"
        }
    }
}

public enum UnifiedCategoryOrderStore {

    public static let key = "goal.category.unifiedOrder"

    public static func save(_ items: [CategoryItem]) {
        let ids = items.map(\.id)
        UserDefaults.standard.set(ids, forKey: key)

        let orderedBuiltin: [GoalCategory] = items.compactMap {
            if case let .builtin(c) = $0 { return c } else { return nil }
        }
        if Set(orderedBuiltin.map(\.rawValue)) == Set(GoalCategory.allCases.map(\.rawValue)) {
            GoalCategoryOrderStore.save(orderedBuiltin)
        }

        let orderedCustom: [CustomGoalCategory] = items.compactMap {
            if case let .custom(c) = $0 { return c } else { return nil }
        }
        CustomGoalCategoriesStore.save(orderedCustom)
    }

    public static func load() -> [CategoryItem] {
        let builtins = GoalCategoryOrderStore.load()
        let customs = CustomGoalCategoriesStore.load()

        let allItems: [CategoryItem] =
            builtins.map(CategoryItem.builtin) + customs.map(CategoryItem.custom)

        guard let storedIds = UserDefaults.standard.array(forKey: key) as? [String] else {
            return allItems
        }

        var byId: [String: CategoryItem] = [:]
        for item in allItems { byId[item.id] = item }

        var result: [CategoryItem] = []
        var used = Set<String>()
        for id in storedIds {
            if let item = byId[id] {
                result.append(item)
                used.insert(id)
            }
        }
        for item in allItems where !used.contains(item.id) {
            result.append(item)
        }
        return result
    }
}
