// ⌘
//  GymNutshellWatch/WatchNotificationsView.swift
//
//  Propósito: Histórico de notificações do Watch (últimos 3 dias).
//             Swipe-to-delete sincroniza com o iPhone via WatchConnectivityManager.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-29.
// ⌘

import SwiftUI
import GymNutshellCore

struct WatchNotificationsView: View {

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
        if store.entries.isEmpty {
            emptyState
        } else {
            List {
                ForEach(grouped, id: \.date) { group in
                    Section(header:
                        Text(sectionTitle(for: group.date))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    ) {
                        ForEach(group.items) { entry in
                            row(for: entry)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        delete(entry)
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
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "bell.slash")
                .font(.system(size: 26))
                .foregroundStyle(.secondary)
            Text(String(localized: "notifications.history.empty.title", bundle: .gymNutshellCore))
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func row(for entry: NotificationHistoryEntry) -> some View {
        let timeString = entry.timestamp.formatted(date: .omitted, time: .shortened)
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 5) {
                icon(for: entry)
                    .accessibilityHidden(true)
                Text(entry.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
            }
            Text(entry.body)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Text(entry.timestamp, style: .time)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.watch.notification.row.format",
                                                 bundle: .gymNutshellCore),
                                   entry.title, entry.body, timeString))
    }

    @ViewBuilder
    private func icon(for entry: NotificationHistoryEntry) -> some View {
        if let emoji = entry.kind?.emoji {
            Text(emoji).font(.system(size: 13))
        } else {
            Image(systemName: entry.kind?.systemIcon ?? "bell")
                .font(.system(size: 12))
                .foregroundStyle(Color.accentColor)
        }
    }

    private func sectionTitle(for date: Date) -> String {
        let label = String(localized: "notifications.history.title", bundle: .gymNutshellCore)
        return "\(label) · \(dayTitle(for: date))"
    }

    private func dayTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return String(localized: "notifications.history.today", bundle: .gymNutshellCore)
        } else if calendar.isDateInYesterday(date) {
            return String(localized: "notifications.history.yesterday", bundle: .gymNutshellCore)
        } else {
            return AppDateFormatters.mediumDate.string(from: date)
        }
    }

    private func delete(_ entry: NotificationHistoryEntry) {
        NotificationHistoryStore.shared.delete(id: entry.id)
        WatchConnectivityManager.shared.sendHistoryDelete(id: entry.id)
    }
}
