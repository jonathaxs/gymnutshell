// ⌘
//  GymNutshellCore/Models/UserProfile.swift
//
//  Propósito: Centraliza as chaves AppStorage dos dados de perfil coletados no onboarding.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-10.
// ⌘

import Foundation

/// Centraliza todas as chaves AppStorage relacionadas ao perfil do usuário.
/// Esses valores são coletados no onboarding e usados pra calcular as metas diárias.
public enum UserProfile {

    // MARK: - Chaves
    public static let nameKey                   = "profile.name"
    public static let weightKey                 = "profile.weight"      // kg, salvo como Double
    public static let heightKey                 = "profile.height"      // cm, salvo como Int
    public static let ageKey                    = "profile.age"         // anos, salvo como Int (derivado de birthdayKey)
    public static let birthdayKey               = "profile.birthday"    // Date.timeIntervalSince1970 (Double)
    public static let sexKey                    = "profile.sex"         // "male" / "female" / "other"
    public static let userGoalKey               = "profile.userGoal"
    public static let favoriteExerciseKey       = "profile.favoriteExercise"
    public static let didCompleteOnboardingKey  = "profile.didCompleteOnboarding"
    public static let measurementSystemKey      = "profile.measurementSystem"
    public static let themeKey                  = AppTheme.storageKey
    public static let colorKey                  = AppAccentColor.storageKey

    // MARK: - Chaves de navegação
    public static let selectedTabKey                  = "app.selectedTab"
    public static let achievementsSelectedDateKey     = "achievements.selectedDate"
    public static let achievementsFilterModeKey       = "achievements.filterMode"

    // MARK: - Data de nascimento

    /// Calcula a idade em anos a partir de uma data de nascimento, usando a data atual.
    public static func age(from birthday: Date, now: Date = Date()) -> Int {
        let comps = Calendar.current.dateComponents([.year], from: birthday, to: now)
        return max(0, comps.year ?? 0)
    }

    /// Lê a data de nascimento salva, se houver.
    public static func storedBirthday() -> Date? {
        let ti = UserDefaults.standard.double(forKey: birthdayKey)
        guard ti > 0 else { return nil }
        return Date(timeIntervalSince1970: ti)
    }

    /// Recalcula a idade a partir da data de nascimento salva e reescreve `ageKey`.
    public static func refreshAgeFromBirthday() {
        guard let birthday = storedBirthday() else { return }
        UserDefaults.standard.set(age(from: birthday), forKey: ageKey)
    }
}

/// Easter egg — exercício/grupo muscular favorito do usuário.
public enum FavoriteExercise: String, CaseIterable, Identifiable, Sendable {
    case unknown
    case back
    case arms
    case chest
    case legs
    case hamstrings
    case glutes
    case shoulders
    case biceps
    case triceps
    case abs
    case traps
    case forearms
    case calves

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .unknown:    return String(localized: "favoriteExercise.unknown", bundle: .gymNutshellCore)
        case .back:       return String(localized: "favoriteExercise.back", bundle: .gymNutshellCore)
        case .arms:       return String(localized: "favoriteExercise.arms", bundle: .gymNutshellCore)
        case .chest:      return String(localized: "favoriteExercise.chest", bundle: .gymNutshellCore)
        case .legs:       return String(localized: "favoriteExercise.legs", bundle: .gymNutshellCore)
        case .hamstrings: return String(localized: "favoriteExercise.hamstrings", bundle: .gymNutshellCore)
        case .glutes:     return String(localized: "favoriteExercise.glutes", bundle: .gymNutshellCore)
        case .shoulders:  return String(localized: "favoriteExercise.shoulders", bundle: .gymNutshellCore)
        case .biceps:     return String(localized: "favoriteExercise.biceps", bundle: .gymNutshellCore)
        case .triceps:    return String(localized: "favoriteExercise.triceps", bundle: .gymNutshellCore)
        case .abs:        return String(localized: "favoriteExercise.abs", bundle: .gymNutshellCore)
        case .traps:      return String(localized: "favoriteExercise.traps", bundle: .gymNutshellCore)
        case .forearms:   return String(localized: "favoriteExercise.forearms", bundle: .gymNutshellCore)
        case .calves:     return String(localized: "favoriteExercise.calves", bundle: .gymNutshellCore)
        }
    }
}

/// Representa o objetivo principal do usuário.
/// Usado pra ajustar os cálculos de macros no onboarding e nas Configurações.
public enum UserGoal: String, CaseIterable, Identifiable, Sendable {
    case bulking
    case maintenance
    case cutting

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .bulking:
            return String(localized: "fitness.goal.bulking", bundle: .gymNutshellCore)
        case .maintenance:
            return String(localized: "fitness.goal.maintenance", bundle: .gymNutshellCore)
        case .cutting:
            return String(localized: "fitness.goal.cutting", bundle: .gymNutshellCore)
        }
    }
}
