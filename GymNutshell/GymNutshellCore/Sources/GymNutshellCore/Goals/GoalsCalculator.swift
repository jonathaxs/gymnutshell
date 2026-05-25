// ⌘
//  GymNutshellCore/Goals/GoalsCalculator.swift
//
//  Propósito: Calcula as metas diárias recomendadas. Macros/hidratação usam peso + objetivo;
//             as calorias usam Mifflin-St Jeor (peso, altura, idade, sexo) → TDEE → ajuste por objetivo.
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
        public let calories: Int   // kcal (Mifflin-St Jeor → TDEE → ajuste por objetivo)
        public let water: Int      // ml
        public let protein: Int    // g
        public let carbs: Int      // g
        public let goodFat: Int    // g
        public let fiber: Int      // g (14g por 1000 kcal)
        public let sleep: Int      // h (fixo)
        public let creatine: Int   // g (baseado no peso; mínimo 3g)
        public let workout: Int    // min (fixo = DefaultGoals.workout)
        public let cardio: Int     // min (fixo = DefaultGoals.cardio)

        public init(
            calories: Int,
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
            self.calories = calories
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

    public static func calculate(
        weightKg: Double,
        heightCm: Int,
        age: Int,
        sex: String,
        goal: UserGoal
    ) -> Result {
        let calories = calculatedCalories(weightKg: weightKg, heightCm: heightCm, age: age, sex: sex, goal: goal)
        let water    = calculatedWater(weightKg: weightKg)
        let protein  = calculatedProtein(weightKg: weightKg, goal: goal)
        let carbs    = calculatedCarbs(weightKg: weightKg, goal: goal)
        let goodFat  = calculatedGoodFat(weightKg: weightKg, goal: goal)
        let fiber    = calculatedFiber(calories: calories)

        let creatine = calculatedCreatine(weightKg: weightKg)

        return Result(
            calories: calories,
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

    /// Calorias diárias recomendadas via Mifflin-St Jeor (BMR) → TDEE → ajuste pelo objetivo.
    /// BMR = 10·kg + 6.25·cm − 5·idade + constante de sexo (♂ +5 / ♀ −161; −78 neutro p/ "other").
    /// TDEE usa fator 1.55 (atividade moderada, treino 3–5x/semana), padrão sensato pra um app de academia.
    /// Ajuste: cutting −20% (déficit), manutenção 0, bulking +15% (superávit leve).
    private static func calculatedCalories(weightKg: Double, heightCm: Int, age: Int, sex: String, goal: UserGoal) -> Int {
        // Defesa contra perfil incompleto: usa valores adultos médios se faltar altura/idade.
        let h = heightCm > 0 ? Double(heightCm) : 170
        let a = age > 0 ? Double(age) : 30

        let sexConstant: Double
        switch sex.lowercased() {
        case "female": sexConstant = -161
        case "male":   sexConstant = 5
        default:       sexConstant = -78   // média dos dois, neutro pra "other"/não informado
        }

        let bmr = 10 * weightKg + 6.25 * h - 5 * a + sexConstant
        let tdee = bmr * 1.55

        let adjusted: Double
        switch goal {
        case .cutting:     adjusted = tdee * 0.80
        case .maintenance: adjusted = tdee
        case .bulking:     adjusted = tdee * 1.15
        }

        return roundToNearest(adjusted, step: 50)
    }

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

    /// Fibra baseada na diretriz dietética de ~14 g por 1000 kcal.
    /// Como deriva das calorias, escala naturalmente por sexo, tamanho e objetivo.
    private static func calculatedFiber(calories: Int) -> Int {
        let raw = Double(calories) / 1000 * 14
        return max(roundToNearest(raw, step: 1), 21)
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
