// ⌘
//  GymNutshellCore/Stores/NotificationHistoryStore.swift
//
//  Propósito: Persistência do histórico de notificações de evento disparadas pelo app.
//             Limita os registros aos últimos 3 dias.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-24.
// ⌘

import Foundation
import Observation

@MainActor
@Observable
public final class NotificationHistoryStore {

    @MainActor public static let shared = NotificationHistoryStore()

    @ObservationIgnored private static let storageKey = "notifications.history.v1"
    @ObservationIgnored private static let retentionDays = 3

    public private(set) var entries: [NotificationHistoryEntry] = []

    private init() {
        load()
    }

    // MARK: - API

    /// Adiciona uma nova entrada no topo do histórico e poda entradas com mais de 3 dias.
    public func append(
        kind: NotificationKind,
        title: String,
        body: String,
        route: NotificationRoute,
        achievementDate: Date? = nil
    ) {
        let entry = NotificationHistoryEntry(
            id: UUID(),
            kindRaw: kind.rawValue,
            title: title,
            body: body,
            timestamp: Date(),
            routeRaw: route.rawValue,
            achievementDate: achievementDate
        )
        var updated = entries
        updated.insert(entry, at: 0)
        updated = prune(updated)
        entries = updated
        persist()
    }

    /// Remove uma entrada específica pelo ID. Persiste imediatamente.
    public func delete(id: UUID) {
        entries.removeAll { $0.id == id }
        persist()
    }

    /// Limpa todo o histórico — usado no teste de setup ou ação de "limpar".
    public func clear() {
        entries = []
        persist()
    }

    /// Substitui o histórico local com dados recebidos via WatchConnectivity.
    /// Poda entradas com mais de 3 dias antes de persistir.
    /// Chamado apenas pelo WatchConnectivityManager — não dispara sync de volta.
    public func applyRemote(_ data: Data) {
        do {
            let decoded = try JSONDecoder().decode([NotificationHistoryEntry].self, from: data)
            entries = prune(decoded)
            persist()
        } catch {
            // Histórico remoto malformado — não sobrescreve o local.
        }
    }

    // MARK: - Persistência

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([NotificationHistoryEntry].self, from: data)
            entries = prune(decoded)
        } catch {
            entries = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        } catch {
            // Falha de serialização é silenciosa — o histórico não é crítico.
        }
    }

    private func prune(_ list: [NotificationHistoryEntry]) -> [NotificationHistoryEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -Self.retentionDays, to: Date())
            ?? Date.distantPast
        return list.filter { $0.timestamp >= cutoff }
    }
}
