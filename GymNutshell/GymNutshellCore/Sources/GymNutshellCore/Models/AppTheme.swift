// ⌘
//  GymNutshellCore/Models/AppTheme.swift
//
//  Propósito: Define o sistema de temas visuais do Gym Nutshell.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-28.
// ⌘

import Foundation

// MARK: - AppTheme

public enum AppTheme: String, CaseIterable, Sendable {
    case gym
    case cat
    case dog
    case bear
    case bird
    case ocean
    case dragon
    case horse
    case monkey
    case fire
    case plant
    case champion
    case ninja
    case astronaut

    public static let storageKey = "app.theme"

    // MARK: - Categoria

    public enum ThemeCategory: CaseIterable, Sendable {
        case sport
        case animals
        case competition
        case elements
        case space
        case warrior

        public var localizedName: String {
            switch self {
            case .sport:       return String(localized: "app.theme.category.sport", bundle: .module)
            case .animals:     return String(localized: "app.theme.category.animals", bundle: .module)
            case .elements:    return String(localized: "app.theme.category.elements", bundle: .module)
            case .competition: return String(localized: "app.theme.category.competition", bundle: .module)
            case .warrior:     return String(localized: "app.theme.category.warrior", bundle: .module)
            case .space:       return String(localized: "app.theme.category.space", bundle: .module)
            }
        }

        public func localizedName(sex: String) -> String {
            guard self == .warrior, sex != "male" else { return localizedName }
            let femValue = NSLocalizedString("app.theme.category.warrior.fem", bundle: .module, comment: "")
            return femValue != "app.theme.category.warrior.fem" ? femValue : localizedName
        }
    }

    public var category: ThemeCategory {
        switch self {
        case .gym: return .sport
        case .cat, .dog, .bear, .bird, .ocean, .dragon, .horse, .monkey: return .animals
        case .fire, .plant: return .elements
        case .champion: return .competition
        case .ninja: return .warrior
        case .astronaut: return .space
        }
    }

    public static func themes(in category: ThemeCategory) -> [AppTheme] {
        allCases.filter { $0.category == category }
    }

    // MARK: - Emoji por nível

    public func emoji(for tier: DailyAchievement) -> String {
        switch self {
        case .gym:
            switch tier {
            case .level1: return "🐓"
            case .level2: return "💪"
            case .level3: return "🐀"
            case .level4: return "🏋️‍♂️"
            }
        case .cat:
            switch tier {
            case .level1: return "🐱"
            case .level2: return "🐈"
            case .level3: return "🐆"
            case .level4: return "🦁"
            }
        case .dog:
            switch tier {
            case .level1: return "🐶"
            case .level2: return "🐩"
            case .level3: return "🐕‍🦺"
            case .level4: return "🐕"
            }
        case .bear:
            switch tier {
            case .level1: return "🧸"
            case .level2: return "🐻"
            case .level3: return "🐻‍❄️"
            case .level4: return "🦬"
            }
        case .bird:
            switch tier {
            case .level1: return "🐣"
            case .level2: return "🐦"
            case .level3: return "🦅"
            case .level4: return "🦉"
            }
        case .ocean:
            switch tier {
            case .level1: return "🐟"
            case .level2: return "🐬"
            case .level3: return "🦈"
            case .level4: return "🐋"
            }
        case .dragon:
            switch tier {
            case .level1: return "🥚"
            case .level2: return "🦎"
            case .level3: return "🐉"
            case .level4: return "🐲"
            }
        case .horse:
            switch tier {
            case .level1: return "🐴"
            case .level2: return "🏇"
            case .level3: return "🦄"
            case .level4: return "🎠"
            }
        case .monkey:
            switch tier {
            case .level1: return "🐒"
            case .level2: return "🐵"
            case .level3: return "🦍"
            case .level4: return "🦧"
            }
        case .fire:
            switch tier {
            case .level1: return "🕯️"
            case .level2: return "🔥"
            case .level3: return "🌋"
            case .level4: return "🌞"
            }
        case .plant:
            switch tier {
            case .level1: return "🌱"
            case .level2: return "🌿"
            case .level3: return "🌳"
            case .level4: return "🎄"
            }
        case .champion:
            switch tier {
            case .level1: return "🥉"
            case .level2: return "🥈"
            case .level3: return "🥇"
            case .level4: return "💪"
            }
        case .ninja:
            switch tier {
            case .level1: return "🥋"
            case .level2: return "🥷"
            case .level3: return "⚔️"
            case .level4: return "🎯"
            }
        case .astronaut:
            switch tier {
            case .level1: return "🧑‍🚀"
            case .level2: return "🛰️"
            case .level3: return "🚀"
            case .level4: return "🛸"
            }
        }
    }

    // MARK: - Nome localizado por nível

    public func name(for tier: DailyAchievement) -> String {
        let key: String
        switch self {
        case .gym:
            switch tier {
            case .level1: key = "daily.achievement.gym.level1"
            case .level2: key = "daily.achievement.gym.level2"
            case .level3: key = "daily.achievement.gym.level3"
            case .level4: key = "daily.achievement.gym.level4"
            }
        case .cat:
            switch tier {
            case .level1: key = "daily.achievement.level1"
            case .level2: key = "daily.achievement.level2"
            case .level3: key = "daily.achievement.level3"
            case .level4: key = "daily.achievement.level4"
            }
        case .dog:
            switch tier {
            case .level1: key = "daily.achievement.dog.level1"
            case .level2: key = "daily.achievement.dog.level2"
            case .level3: key = "daily.achievement.dog.level3"
            case .level4: key = "daily.achievement.dog.level4"
            }
        case .bear:
            switch tier {
            case .level1: key = "daily.achievement.bear.level1"
            case .level2: key = "daily.achievement.bear.level2"
            case .level3: key = "daily.achievement.bear.level3"
            case .level4: key = "daily.achievement.bear.level4"
            }
        case .bird:
            switch tier {
            case .level1: key = "daily.achievement.bird.level1"
            case .level2: key = "daily.achievement.bird.level2"
            case .level3: key = "daily.achievement.bird.level3"
            case .level4: key = "daily.achievement.bird.level4"
            }
        case .ocean:
            switch tier {
            case .level1: key = "daily.achievement.ocean.level1"
            case .level2: key = "daily.achievement.ocean.level2"
            case .level3: key = "daily.achievement.ocean.level3"
            case .level4: key = "daily.achievement.ocean.level4"
            }
        case .dragon:
            switch tier {
            case .level1: key = "daily.achievement.dragon.level1"
            case .level2: key = "daily.achievement.dragon.level2"
            case .level3: key = "daily.achievement.dragon.level3"
            case .level4: key = "daily.achievement.dragon.level4"
            }
        case .horse:
            switch tier {
            case .level1: key = "daily.achievement.horse.level1"
            case .level2: key = "daily.achievement.horse.level2"
            case .level3: key = "daily.achievement.horse.level3"
            case .level4: key = "daily.achievement.horse.level4"
            }
        case .monkey:
            switch tier {
            case .level1: key = "daily.achievement.monkey.level1"
            case .level2: key = "daily.achievement.monkey.level2"
            case .level3: key = "daily.achievement.monkey.level3"
            case .level4: key = "daily.achievement.monkey.level4"
            }
        case .fire:
            switch tier {
            case .level1: key = "daily.achievement.fire.level1"
            case .level2: key = "daily.achievement.fire.level2"
            case .level3: key = "daily.achievement.fire.level3"
            case .level4: key = "daily.achievement.fire.level4"
            }
        case .plant:
            switch tier {
            case .level1: key = "daily.achievement.plant.level1"
            case .level2: key = "daily.achievement.plant.level2"
            case .level3: key = "daily.achievement.plant.level3"
            case .level4: key = "daily.achievement.plant.level4"
            }
        case .champion:
            switch tier {
            case .level1: key = "daily.achievement.champion.level1"
            case .level2: key = "daily.achievement.champion.level2"
            case .level3: key = "daily.achievement.champion.level3"
            case .level4: key = "daily.achievement.champion.level4"
            }
        case .ninja:
            switch tier {
            case .level1: key = "daily.achievement.ninja.level1"
            case .level2: key = "daily.achievement.ninja.level2"
            case .level3: key = "daily.achievement.ninja.level3"
            case .level4: key = "daily.achievement.ninja.level4"
            }
        case .astronaut:
            switch tier {
            case .level1: key = "daily.achievement.astronaut.level1"
            case .level2: key = "daily.achievement.astronaut.level2"
            case .level3: key = "daily.achievement.astronaut.level3"
            case .level4: key = "daily.achievement.astronaut.level4"
            }
        }
        return String(localized: String.LocalizationValue(key), bundle: .module)
    }

    // MARK: - Nome localizado por nível e sexo

    public func name(for tier: DailyAchievement, sex: String) -> String {
        guard sex != "male" else { return name(for: tier) }

        let masculineKey: String
        switch self {
        case .cat:
            switch tier {
            case .level1: masculineKey = "daily.achievement.level1"
            case .level2: masculineKey = "daily.achievement.level2"
            case .level3: masculineKey = "daily.achievement.level3"
            case .level4: masculineKey = "daily.achievement.level4"
            }
        default:
            let baseName = name(for: tier)
            let themePrefix: String
            switch self {
            case .gym:       themePrefix = "daily.achievement.gym"
            case .bear:      themePrefix = "daily.achievement.bear"
            case .horse:     themePrefix = "daily.achievement.horse"
            case .dog:       themePrefix = "daily.achievement.dog"
            case .dragon:    themePrefix = "daily.achievement.dragon"
            default:         return baseName
            }
            let tierSuffix: String
            switch tier {
            case .level1: tierSuffix = "level1"
            case .level2: tierSuffix = "level2"
            case .level3: tierSuffix = "level3"
            case .level4: tierSuffix = "level4"
            }
            let femKey = "\(themePrefix).\(tierSuffix).fem"
            let femValue = NSLocalizedString(femKey, bundle: .module, comment: "")
            return femValue != femKey ? femValue : baseName
        }
        let femKey = masculineKey + ".fem"
        let femValue = NSLocalizedString(femKey, comment: "")
        return femValue != femKey ? femValue : String(localized: String.LocalizationValue(masculineKey), bundle: .module)
    }

    // MARK: - Helpers de exibição

    public func displayName(sex: String) -> String {
        guard sex != "male" else { return displayName }
        let femKey: String
        switch self {
        case .gym:    femKey = "app.theme.gym.fem"
        case .cat:    femKey = "app.theme.cat.fem"
        case .bear:   femKey = "app.theme.bear.fem"
        case .horse:  femKey = "app.theme.horse.fem"
        case .dog:    femKey = "app.theme.dog.fem"
        case .dragon: femKey = "app.theme.dragon.fem"
        default:      return displayName
        }
        let femValue = NSLocalizedString(femKey, comment: "")
        return femValue != femKey ? femValue : displayName
    }

    public var displayName: String {
        let key: String
        switch self {
        case .gym:    key = "app.theme.gym"
        case .cat:    key = "app.theme.cat"
        case .dog:    key = "app.theme.dog"
        case .bear:   key = "app.theme.bear"
        case .bird:   key = "app.theme.bird"
        case .ocean:  key = "app.theme.ocean"
        case .dragon: key = "app.theme.dragon"
        case .horse:  key = "app.theme.horse"
        case .monkey:    key = "app.theme.monkey"
        case .fire:      key = "app.theme.fire"
        case .plant:     key = "app.theme.plant"
        case .champion:  key = "app.theme.champion"
        case .ninja:     key = "app.theme.ninja"
        case .astronaut: key = "app.theme.astronaut"
        }
        return String(localized: String.LocalizationValue(key), bundle: .module)
    }

    public var themeEmojis: String {
        DailyAchievement.allCases.map { emoji(for: $0) }.joined()
    }

    public func emoji(for tier: DailyAchievement, sex: String) -> String {
        if self == .gym, sex != "male" {
            switch tier {
            case .level1: return "🐔"
            case .level3: return "🐁"
            default: break
            }
        }
        return emoji(for: tier)
    }

    public func themeEmojis(sex: String) -> String {
        DailyAchievement.allCases.map { emoji(for: $0, sex: sex) }.joined()
    }
}

// MARK: - Identifiable

extension AppTheme: Identifiable {
    public var id: String { rawValue }
}
