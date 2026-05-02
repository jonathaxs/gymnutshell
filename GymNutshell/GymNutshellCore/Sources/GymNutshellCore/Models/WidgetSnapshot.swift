// ⌘
//  GymNutshellCore/Models/WidgetSnapshot.swift
//
//  Propósito: Snapshot pré-computado do progresso do dia para widgets e complications.
//             Escrito pelo app principal via WidgetSnapshotStore, lido pelos widget extensions.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-29.
// ⌘

import Foundation

public struct WidgetSnapshot: Codable, Sendable {

    /// Progresso normalizado do dia (0.0–1.0), média de todos os objetivos ativos.
    public let progressNormalized: Double

    /// Nível do tier atual (1–4).
    public let tier: Int

    /// Emoji do tier pré-computado com tema + gênero do usuário.
    public let tierEmoji: String

    /// Nome localizado do tier pré-computado.
    public let tierName: String

    /// Raw value de `AppAccentColor` para aplicar a cor de destaque no widget.
    public let accentColorRaw: String

    /// Momento em que o snapshot foi gerado.
    public let updatedAt: Date

    public var progressPercent: Int { Int((progressNormalized * 100).rounded(.down)) }

    public init(
        progressNormalized: Double,
        tier: Int,
        tierEmoji: String,
        tierName: String,
        accentColorRaw: String,
        updatedAt: Date = Date()
    ) {
        self.progressNormalized = max(0, min(1, progressNormalized))
        self.tier = max(1, min(4, tier))
        self.tierEmoji = tierEmoji
        self.tierName = tierName
        self.accentColorRaw = accentColorRaw
        self.updatedAt = updatedAt
    }

    public static let placeholder = WidgetSnapshot(
        progressNormalized: 0.65,
        tier: 2,
        tierEmoji: "🐈",
        tierName: "---",
        accentColorRaw: AppAccentColor.blue.rawValue
    )
}

// MARK: - Builder (executado apenas no processo do app principal)

extension WidgetSnapshot {

    /// Lê os intakes e metas do `UserDefaults.standard` e calcula o snapshot atual.
    /// Deve ser chamado apenas a partir do app principal (iOS), nunca do widget extension.
    public static func buildCurrent() -> WidgetSnapshot {
        let defaults = UserDefaults.standard

        let allKeys = GoalOrderStore.load()
        let removed = RemovedItemsStore.load()
        let activeKeys = allKeys.filter { !removed.contains($0) }

        var values: [Double] = []
        for key in activeKeys {
            values.append(intakeProgress(key: key, defaults: defaults))
        }

        let dailyProgress = values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        let achievement = DailyAchievement.from(progress: dailyProgress)

        let themeRaw = defaults.string(forKey: AppTheme.storageKey) ?? ""
        let theme = AppTheme(rawValue: themeRaw) ?? .gym
        let sex = defaults.string(forKey: UserProfile.sexKey) ?? ""
        let accentColorRaw = defaults.string(forKey: AppAccentColor.storageKey) ?? AppAccentColor.blue.rawValue

        let tierNumber: Int
        switch achievement {
        case .level1: tierNumber = 1
        case .level2: tierNumber = 2
        case .level3: tierNumber = 3
        case .level4: tierNumber = 4
        }

        return WidgetSnapshot(
            progressNormalized: dailyProgress,
            tier: tierNumber,
            tierEmoji: theme.emoji(for: achievement, sex: sex),
            tierName: theme.name(for: achievement, sex: sex),
            accentColorRaw: accentColorRaw
        )
    }

    private static func intakeProgress(key: String, defaults: UserDefaults) -> Double {
        switch key {
        case "tracking.workout":
            if defaults.bool(forKey: "workoutRestDay") { return 1.0 }
            return ProgressHelpers.normalizedProgress(
                current: defaults.integer(forKey: "workoutIntake"),
                goal: GoalsProvider.workout
            )
        case "tracking.cardio":
            if defaults.bool(forKey: "cardioRestDay") { return 1.0 }
            return ProgressHelpers.normalizedProgress(
                current: defaults.integer(forKey: "cardioIntake"),
                goal: GoalsProvider.cardio
            )
        case "tracking.sleep":
            return ProgressHelpers.normalizedProgress(
                current: defaults.integer(forKey: "sleepHours"),
                goal: GoalsProvider.sleep
            )
        case "tracking.water":
            return ProgressHelpers.normalizedProgress(
                current: defaults.integer(forKey: "waterIntake"),
                goal: GoalsProvider.water
            )
        case "tracking.protein":
            return ProgressHelpers.normalizedProgress(
                current: defaults.integer(forKey: "proteinIntake"),
                goal: GoalsProvider.protein
            )
        case "tracking.carbs":
            return ProgressHelpers.normalizedProgress(
                current: defaults.integer(forKey: "carbIntake"),
                goal: GoalsProvider.carbs
            )
        case "tracking.goodFat":
            return ProgressHelpers.normalizedProgress(
                current: defaults.integer(forKey: "goodFatIntake"),
                goal: GoalsProvider.goodFat
            )
        case "tracking.fiber":
            return ProgressHelpers.normalizedProgress(
                current: defaults.integer(forKey: "fiberIntake"),
                goal: GoalsProvider.fiber
            )
        case "tracking.creatine":
            return ProgressHelpers.normalizedProgress(
                current: defaults.integer(forKey: "creatineIntake"),
                goal: GoalsProvider.creatine
            )
        case "tracking.vitaminD":
            return ProgressHelpers.normalizedProgress(
                current: defaults.integer(forKey: "vitaminDIntake"),
                goal: GoalsProvider.vitaminD
            )
        default:
            return 0
        }
    }
}
