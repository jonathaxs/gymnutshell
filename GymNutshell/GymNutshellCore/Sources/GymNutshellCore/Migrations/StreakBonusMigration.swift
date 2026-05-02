// ⌘
//  GymNutshellCore/Migrations/StreakBonusMigration.swift
//
//  Propósito: Migração one-shot que reescreve as strings antigas de StreakBonus.bonusType
//             (weekly.strong/expert, monthly.strong/expert) para o novo padrão de nomenclatura
//             por nível (weekly.level3/level4, monthly.level3/level4).
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-21.
// ⌘

import Foundation
import SwiftData

public enum StreakBonusMigration {

    private static let flagKey = "migration.streakBonus.tiers.v1.done"

    private static let renames: [String: String] = [
        "weekly.strong":  "weekly.level3",
        "weekly.expert":  "weekly.level4",
        "monthly.strong": "monthly.level3",
        "monthly.expert": "monthly.level4",
    ]

    public static func runIfNeeded(in modelContext: ModelContext) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: flagKey) else { return }

        guard let bonuses = try? modelContext.fetch(FetchDescriptor<StreakBonus>()) else { return }

        for bonus in bonuses {
            if let renamed = renames[bonus.bonusType] {
                bonus.bonusType = renamed
            }
        }

        try? modelContext.save()
        defaults.set(true, forKey: flagKey)
    }
}
