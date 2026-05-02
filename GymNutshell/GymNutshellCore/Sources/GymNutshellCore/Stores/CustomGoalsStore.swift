// ⌘
//  GymNutshellCore/Stores/CustomGoalsStore.swift
//
//  Propósito: Persiste e recupera metas de rastreio criadas pelo usuário e seus valores de ingestão diários.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-11.
// ⌘

import Foundation

// MARK: - CustomTrackingGoalsStore

public enum CustomTrackingGoalsStore {

    private static let key = "customGoals"

    public static func load() -> [CustomTrackingGoal] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let goals = try? JSONDecoder().decode([CustomTrackingGoal].self, from: data)
        else { return [] }
        return goals
    }

    public static func save(_ goals: [CustomTrackingGoal]) {
        guard let data = try? JSONEncoder().encode(goals) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    public static func upsert(_ trackingGoal: CustomTrackingGoal) {
        var all = load()
        if let index = all.firstIndex(where: { $0.id == trackingGoal.id }) {
            all[index] = trackingGoal
        } else {
            all.append(trackingGoal)
        }
        save(all)
    }

    public static func delete(ids: [UUID]) {
        var all = load()
        all.removeAll { ids.contains($0.id) }
        save(all)
    }
}

// MARK: - CustomTrackingIntakesStore

public enum CustomTrackingIntakesStore {

    private static let key = "customIntakes"

    public static func load() -> [String: Int] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let dict = try? JSONDecoder().decode([String: Int].self, from: data)
        else { return [:] }
        return dict
    }

    public static func save(_ dict: [String: Int]) {
        guard let data = try? JSONEncoder().encode(dict) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    public static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - CustomTrackingRestDaysStore

public enum CustomTrackingRestDaysStore {

    private static let key = "customRestDays"

    public static func load() -> [String: Bool] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let dict = try? JSONDecoder().decode([String: Bool].self, from: data)
        else { return [:] }
        return dict
    }

    public static func save(_ dict: [String: Bool]) {
        guard let data = try? JSONEncoder().encode(dict) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    public static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
