// ⌘
//  GymNutshell/GymNutshellApp/Views/Shared/NotificationHistorySheet.swift
//
//  Propósito: Sheet compartilhada pelas 4 telas principais (Today, Achievements,
//             Statistics, Settings) que mostra o histórico de notificações de evento
//             dos últimos 3 dias. Tap numa entrada dispara o mesmo deep-link da
//             notificação original.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-24.
// ⌘

import SwiftUI
import GymNutshellCore

/// Lista agrupada por dia das notificações de evento disparadas nos últimos 3 dias.
struct NotificationHistorySheet: View {

    @Environment(\.dismiss) private var dismiss
    @Bindable private var store = NotificationHistoryStore.shared

    private var grouped: [(date: Date, items: [NotificationHistoryEntry])] {
        let calendar = Calendar.current
        let buckets = Dictionary(grouping: store.entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        return buckets
            .map { (date: $0.key, items: $0.value.sorted { $0.timestamp > $1.timestamp }) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(grouped, id: \.date) { group in
                            Section(header: Text(dayTitle(for: group.date))) {
                                ForEach(group.items) { entry in
                                    row(for: entry)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                store.delete(id: entry.id)
                                                WatchConnectivityManager.shared.sendHistoryDelete(id: entry.id)
                                            } label: {
                                                Label(
                                                    String(localized: "notifications.history.delete",
                                                           bundle: .gymNutshellCore),
                                                    systemImage: "trash"
                                                )
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(String(localized: "notifications.history.title", bundle: .gymNutshellCore))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "notifications.history.back", bundle: .gymNutshellCore)) { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(String(localized: "notifications.history.empty.title", bundle: .gymNutshellCore))
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(String(localized: "notifications.history.empty.description", bundle: .gymNutshellCore))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func row(for entry: NotificationHistoryEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            icon(for: entry)
                .frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.subheadline.weight(.semibold))
                Text(entry.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap(entry)
        }
    }

    @ViewBuilder
    private func icon(for entry: NotificationHistoryEntry) -> some View {
        if let emoji = entry.kind?.emoji {
            Text(emoji).font(.title3)
        } else if let symbol = entry.kind?.systemIcon {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
        } else {
            Image(systemName: "bell")
                .font(.title3)
                .foregroundStyle(Color.accentColor)
        }
    }

    private func dayTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return String(localized: "notifications.history.today", bundle: .gymNutshellCore)
        } else if calendar.isDateInYesterday(date) {
            return String(localized: "notifications.history.yesterday", bundle: .gymNutshellCore)
        } else {
            let formatter = DateFormatter()
            formatter.locale = .current
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }

    /// Dispara o mesmo deep-link que a notificação original acionaria.
    private func handleTap(_ entry: NotificationHistoryEntry) {
        guard let route = entry.route else { return }
        var userInfo: [String: Any] = ["route": route.rawValue]
        if let achievementDate = entry.achievementDate {
            userInfo["achievementDate"] = achievementDate.timeIntervalSince1970
        }
        dismiss()
        // Pequeno delay pra garantir que a sheet fechou antes do deep-link mudar de tab.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NotificationCenter.default.post(
                name: .gaNotificationRoute,
                object: nil,
                userInfo: userInfo
            )
        }
    }
}
