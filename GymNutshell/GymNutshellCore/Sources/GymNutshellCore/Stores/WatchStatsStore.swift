// ⌘
//  GymNutshellCore/Stores/WatchStatsStore.swift
//
//  Propósito: Armazena o snapshot de estatísticas recebido do iPhone via WatchConnectivity.
//             Persiste no UserDefaults pra sobreviver ao reinício do Watch app.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-29.
// ⌘

import Foundation
import Observation

@MainActor
@Observable
public final class WatchStatsStore {

    @MainActor public static let shared = WatchStatsStore()

    @ObservationIgnored private static let storageKey = "watch.stats.summary.v1"

    public private(set) var summary: WatchStatsSummary? = nil

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey) {
            summary = try? JSONDecoder().decode(WatchStatsSummary.self, from: data)
        }
    }

    /// Decodifica e aplica o snapshot recebido via WatchConnectivity. Persiste localmente.
    public func apply(_ data: Data) {
        guard let decoded = try? JSONDecoder().decode(WatchStatsSummary.self, from: data) else { return }
        summary = decoded
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
