// ⌘
//  GymNutshellCore/Goals/OrderedGoalsResolver.swift
//
//  Propósito: Resolve a lista canônica de metas built-in ativas, ordenada por
//             categoria → meta. Centraliza a regra pra evitar que cada view
//             re-implemente e introduza bugs de "Treino sempre no topo".
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-05-15.
// ⌘

import Foundation

public enum OrderedGoalsResolver {

    /// Retorna as chaves `tracking.*` ativas (não removidas) na ordem correta:
    /// primeiro pela ordem do `GoalCategoryOrderStore`, depois pela ordem do
    /// `GoalOrderStore` dentro de cada categoria. Respeita o modo VitaminD.
    ///
    /// Esta é a fonte da verdade, toda view que itera metas built-in deveria
    /// passar por aqui em vez de chamar `GoalOrderStore.load()` direto.
    public static func orderedActiveBuiltinKeys() -> [String] {
        let removed = RemovedItemsStore.load()
        let goalOrder = GoalOrderStore.load().filter { !removed.contains($0) }
        let categoryOrder = GoalCategoryOrderStore.load()

        let vitaminDRaw = UserDefaults.standard.string(forKey: GoalCategory.vitaminDCategoryKey)
            ?? GoalCategory.vitamina.rawValue
        let vitaminDCategory = GoalCategory(rawValue: vitaminDRaw) ?? .vitamina

        var result: [String] = []
        var used = Set<String>()

        for category in categoryOrder {
            for key in goalOrder where !used.contains(key) {
                let effective = GoalCategory.effectiveCategory(
                    for: key,
                    vitaminDCategory: vitaminDCategory
                )
                if effective == category {
                    result.append(key)
                    used.insert(key)
                }
            }
        }

        // Defesa: chaves sem categoria reconhecida vão pro final na ordem do GoalOrderStore.
        for key in goalOrder where !used.contains(key) {
            result.append(key)
        }

        return result
    }
}
