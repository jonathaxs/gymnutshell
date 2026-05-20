// ⌘
//  GymNutshellCore/Services/BackupManager.swift
//
//  Propósito: Codifica e decodifica o estado completo do app como um arquivo JSON de backup.
//             O insert/delete real no SwiftData acontece nas views, já que precisa do ModelContext.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-12.
// ⌘

import Foundation
import SwiftData

// MARK: - BackupManager

public enum BackupManager {

    // MARK: - Exportar

    public static func export(records: [DailyRecord]) throws -> Data {
        let defaults = UserDefaults.standard

        let profile = BackupPayload.ProfileSnapshot(
            name:              defaults.string(forKey: UserProfile.nameKey) ?? "",
            username:          nil,
            height:            defaults.integer(forKey: UserProfile.heightKey),
            weight:            defaults.double(forKey: UserProfile.weightKey),
            age:               defaults.integer(forKey: UserProfile.ageKey),
            sex:               defaults.string(forKey: UserProfile.sexKey) ?? "",
            userGoal:          defaults.string(forKey: UserProfile.userGoalKey) ?? "",
            measurementSystem: defaults.string(forKey: UserProfile.measurementSystemKey)
        )

        let appearance = BackupPayload.AppearanceSnapshot(
            theme:       defaults.string(forKey: AppTheme.storageKey) ?? AppTheme.gym.rawValue,
            accentColor: defaults.string(forKey: AppAccentColor.storageKey) ?? AppAccentColor.blue.rawValue
        )

        let customCategories     = CustomGoalCategoriesStore.load()
        let categoryOrderIds     = UnifiedCategoryOrderStore.load().map(\.id)
        let builtinCategoryOrder = GoalCategoryOrderStore.load().map(\.rawValue)
        let vitaminDMode         = defaults.string(forKey: GoalCategory.vitaminDCategoryKey)

        let goals = BackupPayload.GoalsSnapshot(
            sleep:   GoalsProvider.sleep,
            water:   GoalsProvider.water,
            protein: GoalsProvider.protein,
            carbs:   GoalsProvider.carbs,
            goodFat: GoalsProvider.goodFat,
            fiber:   GoalsProvider.fiber
        )

        let goalsOrder          = GoalOrderStore.load()
        let customGoals         = CustomTrackingGoalsStore.load()
        let removedItems        = Array(RemovedItemsStore.load())

        let snapshots = records.map { r -> BackupPayload.RecordSnapshot in
            let customValues = (try? JSONDecoder().decode([String: Int].self, from: r.customValues)) ?? [:]
            return BackupPayload.RecordSnapshot(
                date:         r.date,
                water:        r.water,
                protein:      r.protein,
                carbs:        r.carbs,
                goodFat:      r.goodFat,
                fiber:        r.fiber,
                sleep:        r.sleep,
                percent:      r.percent,
                achievementTitle: r.achievementTitle,
                achievementEmoji: r.achievementEmoji,
                points:       r.points,
                didWorkout:   r.didWorkout,
                didCardio:    r.didCardio,
                customValues: customValues
            )
        }

        let payload = BackupPayload(
            version:              3,
            exportedAt:           Date(),
            profile:              profile,
            goals:                goals,
            goalsOrder:           goalsOrder,
            customGoals:          customGoals,
            removedItems:         removedItems,
            dailyRecords:         snapshots,
            appearance:           appearance,
            customCategories:     customCategories,
            categoryOrder:        categoryOrderIds,
            builtinCategoryOrder: builtinCategoryOrder,
            vitaminDCategoryMode: vitaminDMode
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting     = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(payload)
    }

    // MARK: - Decodificar

    public static func decode(_ data: Data) throws -> BackupPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(BackupPayload.self, from: data)
    }

    // MARK: - Restaurar (somente UserDefaults)

    public static func restoreUserDefaults(from payload: BackupPayload) {
        let defaults = UserDefaults.standard
        let p = payload.profile

        defaults.set(p.name,        forKey: UserProfile.nameKey)
        defaults.set(p.height,      forKey: UserProfile.heightKey)
        defaults.set(p.weight,      forKey: UserProfile.weightKey)
        defaults.set(p.age,         forKey: UserProfile.ageKey)
        defaults.set(p.sex,         forKey: UserProfile.sexKey)
        defaults.set(p.userGoal,    forKey: UserProfile.userGoalKey)
        if let system = p.measurementSystem {
            defaults.set(system, forKey: UserProfile.measurementSystemKey)
        }

        let g = payload.goals
        defaults.set(g.sleep,   forKey: "tracking.sleep")
        defaults.set(g.water,   forKey: "tracking.water")
        defaults.set(g.protein, forKey: "tracking.protein")
        defaults.set(g.carbs,   forKey: "tracking.carbs")
        defaults.set(g.goodFat, forKey: "tracking.goodFat")
        defaults.set(g.fiber,   forKey: "tracking.fiber")

        GoalOrderStore.save(payload.goalsOrder)
        CustomTrackingGoalsStore.save(payload.customGoals)

        if let removed = payload.removedItems {
            RemovedItemsStore.save(removed)
        }

        if let appearance = payload.appearance {
            defaults.set(appearance.theme,       forKey: AppTheme.storageKey)
            defaults.set(appearance.accentColor, forKey: AppAccentColor.storageKey)
        }

        if let customCategories = payload.customCategories {
            CustomGoalCategoriesStore.save(customCategories)
        }
        if let builtinOrder = payload.builtinCategoryOrder {
            let categories = builtinOrder.compactMap { GoalCategory(rawValue: $0) }
            if !categories.isEmpty {
                GoalCategoryOrderStore.save(categories)
            }
        }
        if let categoryOrder = payload.categoryOrder {
            defaults.set(categoryOrder, forKey: UnifiedCategoryOrderStore.key)
        }

        if let vitaminDMode = payload.vitaminDCategoryMode {
            defaults.set(vitaminDMode, forKey: GoalCategory.vitaminDCategoryKey)
        }
    }

    // MARK: - Aplicar backup completo

    /// Restaura um `BackupPayload` por inteiro: apaga os `DailyRecord` existentes,
    /// reaplica UserDefaults/metas/preferências e reinsere os snapshots no SwiftData.
    /// Os 4 fluxos de restauração (Welcome iCloud, Welcome arquivo, painel de
    /// onboarding wide e Settings → Backup) compartilham este método.
    public static func applyPayload(_ payload: BackupPayload, into context: ModelContext) throws {
        try context.delete(model: DailyRecord.self)
        restoreUserDefaults(from: payload)
        for snap in payload.dailyRecords {
            let record = DailyRecord(
                date: snap.date, water: snap.water, protein: snap.protein,
                carbs: snap.carbs, goodFat: snap.goodFat, fiber: snap.fiber,
                sleep: snap.sleep, percent: snap.percent,
                achievementTitle: snap.achievementTitle, achievementEmoji: snap.achievementEmoji,
                points: snap.points
            )
            record.didWorkout = snap.didWorkout
            record.didCardio = snap.didCardio ?? false
            record.customValues = (try? JSONEncoder().encode(snap.customValues)) ?? Data()
            context.insert(record)
        }
    }

    // MARK: - Nome de arquivo sugerido

    public static func suggestedFilename() -> String {
        let name = UserDefaults.standard.string(forKey: UserProfile.nameKey) ?? "user"
        let sanitized = name.lowercased().filter { $0.isLetter || $0.isNumber }
        let dateStr = ISO8601DateFormatter().string(from: Date()).prefix(10)
        return "gymnutshell-\(sanitized)-backup-\(dateStr).json"
    }
}
