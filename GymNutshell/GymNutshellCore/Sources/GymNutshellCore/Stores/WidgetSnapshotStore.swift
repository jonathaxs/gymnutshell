// ⌘
//  GymNutshellCore/Stores/WidgetSnapshotStore.swift
//
//  Propósito: Lê e escreve WidgetSnapshot no App Group UserDefaults compartilhado
//             entre o app principal, Watch app e os widget extensions.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-29.
// ⌘

import Foundation

public enum WidgetSnapshotStore {

    private static let appGroupID = "group.com.jonathaxs.gymnutshell"
    public static let storageKey = "widget.snapshot.v1"

    public static func save(_ snapshot: WidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot),
              let defaults = UserDefaults(suiteName: appGroupID) else { return }
        defaults.set(data, forKey: storageKey)
    }

    public static func load() -> WidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
