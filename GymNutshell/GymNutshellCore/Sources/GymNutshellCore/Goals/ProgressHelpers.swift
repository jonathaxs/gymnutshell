// ⌘
//  GymNutshellCore/Goals/ProgressHelpers.swift
//
//  Propósito: Utilitários compartilhados pra calcular valores de progresso normalizados (fixados em 0…1).
//
//  Created by Jonathas Motta (@jonathaxs) on 2025-12-19.
// ⌘

import Foundation

public enum ProgressHelpers {

    public static func normalizedProgress(current: Int, goal: Int) -> Double {
        clampedProgress(current: current, goal: goal)
    }

    public static func clampedProgress(current: Int, goal: Int) -> Double {
        guard goal > 0 else { return 0.0 }
        let raw = Double(current) / Double(goal)
        return min(max(raw, 0.0), 1.0)
    }

    public static func normalizedProgress(current: Double, goal: Double) -> Double {
        clampedProgress(current: current, goal: goal)
    }

    public static func clampedProgress(current: Double, goal: Double) -> Double {
        guard goal > 0 else { return 0.0 }
        let raw = current / goal
        return min(max(raw, 0.0), 1.0)
    }
}
