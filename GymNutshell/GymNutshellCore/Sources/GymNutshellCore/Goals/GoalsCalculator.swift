// ⌘
//  GymNutshellCore/Goals/GoalsCalculator.swift
//
//  Propósito: Calcula as metas diárias recomendadas baseadas no peso do usuário e no objetivo de fitness.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-10.
// ⌘

import Foundation

/// Calcula as metas diárias recomendadas de macros e hidratação
/// baseadas no peso corporal e no objetivo de fitness do usuário.
public enum GoalsCalculator {

    // MARK: - Resultado

    /// Guarda todas as metas diárias calculadas pra um perfil.
    public struct Result: Sendable {
        public let water: Int      // ml
        public let protein: Int    // g
        public let carbs: Int      // g
        public let goodFat: Int    // g
        public let fiber: Int      // g (varia conforme o objetivo)
        public let sleep: Int      // h (fixo)
        public let creatine: Int   // g (baseado no peso; mínimo 3g)
        public let workout: Int    // min (fixo = DefaultGoals.workout)
        public let cardio: Int     // min (fixo = DefaultGoals.cardio)

        public init(
            water: Int,
            protein: Int,
            carbs: Int,
            goodFat: Int,
            fiber: Int,
            sleep: Int,
            creatine: Int,
            workout: Int,
            cardio: Int
        ) {
            self.water = water
            self.protein = protein
            self.carbs = carbs
            self.goodFat = goodFat
            self.fiber = fiber
            self.sleep = sleep
            self.creatine = creatine
            self.workout = workout
            self.cardio = cardio
        }
    }

    // MARK: - Cálculo

    public static func calculate(weightKg: Double, goal: UserGoal) -> Result {
        let water    = calculatedWater(weightKg: weightKg)
        let protein  = calculatedProtein(weightKg: weightKg, goal: goal)
        let carbs    = calculatedCarbs(weightKg: weightKg, goal: goal)
        let goodFat  = calculatedGoodFat(weightKg: weightKg, goal: goal)
        let fiber    = calculatedFiber(goal: goal)

        let creatine = calculatedCreatine(weightKg: weightKg)

        return Result(
            water: water,
            protein: protein,
            carbs: carbs,
            goodFat: goodFat,
            fiber: fiber,
            sleep: DefaultGoals.sleep,
            creatine: creatine,
            workout: DefaultGoals.workout,
            cardio: DefaultGoals.cardio
        )
    }

    // MARK: - Fórmulas individuais

    private static func calculatedWater(weightKg: Double) -> Int {
        let raw = weightKg * 35
        let rounded = (raw / 250).rounded() * 250
        return max(Int(rounded), 1500)
    }

    private static func calculatedProtein(weightKg: Double, goal: UserGoal) -> Int {
        let multiplier: Double = goal == .cutting ? 2.2 : 2.0
        let raw = weightKg * multiplier
        return roundToNearest(raw, step: 5)
    }

    private static func calculatedCarbs(weightKg: Double, goal: UserGoal) -> Int {
        let multiplier: Double
        switch goal {
        case .bulking:      multiplier = 4.5
        case .maintenance:  multiplier = 3.5
        case .cutting:      multiplier = 2.5
        }
        return roundToNearest(weightKg * multiplier, step: 10)
    }

    private static func calculatedGoodFat(weightKg: Double, goal: UserGoal) -> Int {
        let multiplier: Double
        switch goal {
        case .bulking:      multiplier = 1.1
        case .maintenance:  multiplier = 0.9
        case .cutting:      multiplier = 0.7
        }
        return roundToNearest(weightKg * multiplier, step: 5)
    }

    private static func calculatedFiber(goal: UserGoal) -> Int {
        switch goal {
        case .bulking:      return 35
        case .maintenance:  return 28
        case .cutting:      return 25
        }
    }

    private static func calculatedCreatine(weightKg: Double) -> Int {
        guard weightKg > 0 else { return DefaultGoals.creatine }
        return max(3, min(10, Int((weightKg * 0.05).rounded())))
    }

    // MARK: - Utilitários

    private static func roundToNearest(_ value: Double, step: Int) -> Int {
        let s = Double(step)
        return max(Int((value / s).rounded() * s), step)
    }
}
