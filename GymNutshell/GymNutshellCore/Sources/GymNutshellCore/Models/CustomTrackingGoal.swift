// ⌘
//  GymNutshellCore/Models/CustomTrackingGoal.swift
//
//  Propósito: Define metas de rastreio opcionais criadas pelo usuário.
//             Persistência (load/save) vive no CustomGoalsStore.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-11.
// ⌘

import Foundation

/// Representa uma meta de rastreio personalizada criada pelo usuário (ex: Creatina 5 g/dia).
/// Salva como array JSON no UserDefaults com a chave "customGoals".
public struct CustomTrackingGoal: Codable, Identifiable, Sendable {
    public let id: UUID
    public var emoji: String
    public var name: String
    public var unit: String
    public var goal: Int         // valor alvo diário
    public var increment: Int    // tamanho do passo usado pelos botões de TrackingGoalRow
    public var category: GoalCategory?  // nil = sem categoria (exibida no final das listas)
    public var customCategoryId: String?  // preenchido quando a meta pertence a uma categoria criada pelo usuário

    public init(
        id: UUID = UUID(),
        emoji: String,
        name: String,
        unit: String,
        goal: Int,
        increment: Int,
        category: GoalCategory? = nil,
        customCategoryId: String? = nil
    ) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.unit = unit
        self.goal = goal
        self.increment = increment
        self.category = category
        self.customCategoryId = customCategoryId
    }
}
