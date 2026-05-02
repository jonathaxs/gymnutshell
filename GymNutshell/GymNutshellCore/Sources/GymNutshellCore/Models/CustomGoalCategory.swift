// ⌘
//  GymNutshellCore/Models/CustomGoalCategory.swift
//
//  Propósito: Categoria de meta criada pelo usuário. Criada a partir da AddTrackingGoalView
//             e persistida junto com CustomTrackingGoal via CustomGoalCategoriesStore.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-20.
// ⌘

import Foundation

/// Categoria de meta criada pelo usuário.
/// `supportsRestDay` liga o botão ON/OFF de "dia de descanso" em todas as metas que pertencerem a ela.
public struct CustomGoalCategory: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public var name: String
    public var supportsRestDay: Bool

    public init(id: String = UUID().uuidString, name: String, supportsRestDay: Bool) {
        self.id = id
        self.name = name
        self.supportsRestDay = supportsRestDay
    }
}
