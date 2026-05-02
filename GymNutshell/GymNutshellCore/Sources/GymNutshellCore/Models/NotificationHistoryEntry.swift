// ⌘
//  GymNutshellCore/Models/NotificationHistoryEntry.swift
//
//  Propósito: Registro de uma notificação de evento já disparada pelo app.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-24.
// ⌘

import Foundation

/// Entrada imutável do histórico de notificações de evento (conquista, bônus, saúde, backup).
/// Lembretes de meta baseados em intervalo não entram aqui — são lembretes repetitivos.
public struct NotificationHistoryEntry: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public let kindRaw: String        // NotificationKind.rawValue — salva como String pra sobreviver a renames
    public let title: String
    public let body: String
    public let timestamp: Date
    public let routeRaw: String       // NotificationRoute.rawValue
    /// Data da conquista (quando aplicável) — permite o deep-link do histórico abrir o dia certo.
    public let achievementDate: Date?

    public init(
        id: UUID,
        kindRaw: String,
        title: String,
        body: String,
        timestamp: Date,
        routeRaw: String,
        achievementDate: Date?
    ) {
        self.id = id
        self.kindRaw = kindRaw
        self.title = title
        self.body = body
        self.timestamp = timestamp
        self.routeRaw = routeRaw
        self.achievementDate = achievementDate
    }

    public var kind: NotificationKind? { NotificationKind(rawValue: kindRaw) }
    public var route: NotificationRoute? { NotificationRoute(rawValue: routeRaw) }
}
