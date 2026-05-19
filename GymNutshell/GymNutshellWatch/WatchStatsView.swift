// ⌘
//  GymNutshellWatch/WatchStatsView.swift
//
//  Propósito: Tela de estatísticas do Watch — renderiza o WatchStatsSummary
//             calculado pelo iPhone e sincronizado via WatchConnectivity.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-29.
// ⌘

import SwiftUI
import GymNutshellCore

struct WatchStatsView: View {

    @Bindable private var store = WatchStatsStore.shared
    @AppStorage(AppTheme.storageKey) private var selectedTheme: AppTheme = .gym
    @AppStorage(UserProfile.sexKey) private var sex: String = ""
    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accent: AppAccentColor { AppAccentColor(rawValue: storedColorRaw) ?? .blue }

    var body: some View {
        if let summary = store.summary {
            statsContent(summary)
        } else {
            syncingState
        }
    }

    // MARK: - Estado aguardando sync

    @ViewBuilder
    private var syncingState: some View {
        VStack(spacing: 10) {
            Image(systemName: "iphone.and.arrow.forward")
                .font(.system(size: 26))
                .foregroundStyle(.secondary)
            Text(String(localized: "watch.stats.syncing", bundle: .gymNutshellCore))
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Conteúdo das estatísticas

    @ViewBuilder
    private func statsContent(_ s: WatchStatsSummary) -> some View {
        List {
            // Pontos e dias — duas colunas no topo
            Section {
                HStack(spacing: 6) {
                    statCard(
                        value: formatted(s.totalPoints),
                        label: String(localized: "watch.stats.points", bundle: .gymNutshellCore)
                    )
                    statCard(
                        value: "\(s.totalDays)",
                        label: String(localized: "watch.stats.days", bundle: .gymNutshellCore)
                    )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            // Tiers
            Section(
                header: Text(String(localized: "statistics.section.tiers", bundle: .gymNutshellCore))
                    .font(.system(size: 11, weight: .semibold))
            ) {
                ForEach(DailyAchievement.allCases, id: \.self) { tier in
                    tierRow(tier: tier, days: days(for: tier, in: s))
                }
            }

            // Atividade
            Section(
                header: Text(String(localized: "statistics.section.activity", bundle: .gymNutshellCore))
                    .font(.system(size: 11, weight: .semibold))
            ) {
                activityRow(emoji: "🏋️",
                            label: String(localized: "statistics.activity.workout", bundle: .gymNutshellCore),
                            days: s.workoutDays)
                activityRow(emoji: "🏃",
                            label: String(localized: "statistics.activity.cardio", bundle: .gymNutshellCore),
                            days: s.cardioDays)
            }

            // Últimos 7 dias
            Section(
                header: Text(String(localized: "watch.stats.recent", bundle: .gymNutshellCore))
                    .font(.system(size: 11, weight: .semibold))
            ) {
                recentDaysStrip(s.last7Days)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Componentes

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(accent.color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }

    private func tierRow(tier: DailyAchievement, days: Int) -> some View {
        let name = selectedTheme.name(for: tier, sex: sex)
        return HStack {
            Text(selectedTheme.emoji(for: tier, sex: sex))
                .font(.system(size: 13))
                .accessibilityHidden(true)
            Text(name)
                .font(.system(size: 12))
                .lineLimit(1)
            Spacer()
            Text(String(format: String(localized: "statistics.tier.days", bundle: .gymNutshellCore), days))
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.stats.tier.row.format",
                                                 bundle: .gymNutshellCore), name, days))
    }

    private func activityRow(emoji: String, label: String, days: Int) -> some View {
        HStack {
            Text(emoji).font(.system(size: 13))
                .accessibilityHidden(true)
            Text(label)
                .font(.system(size: 12))
                .lineLimit(1)
            Spacer()
            Text(String(format: String(localized: "statistics.tier.days", bundle: .gymNutshellCore), days))
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.stats.activity.row.format",
                                                 bundle: .gymNutshellCore), label, days))
    }

    private func recentDaysStrip(_ days: [WatchStatsSummary.DayEntry]) -> some View {
        let activeDays = days.filter { !$0.emoji.isEmpty }.count
        return HStack(spacing: 3) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                ZStack {
                    Circle()
                        .fill(day.emoji.isEmpty
                              ? Color.secondary.opacity(0.2)
                              : accent.color.opacity(0.2))
                        .frame(width: 28, height: 28)
                    if day.emoji.isEmpty {
                        Circle()
                            .fill(Color.secondary.opacity(0.4))
                            .frame(width: 8, height: 8)
                    } else {
                        Text(day.emoji)
                            .font(.system(size: 14))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        // Tela do Watch é pequena demais pra navegar célula por célula —
        // colapsa a faixa num resumo único "Recente: X dias com conquistas em 7".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: String(localized: "a11y.watch.recent.summary.format",
                                                 bundle: .gymNutshellCore),
                                   String(localized: "watch.stats.recent", bundle: .gymNutshellCore),
                                   activeDays))
    }

    // MARK: - Helpers

    private func days(for tier: DailyAchievement, in s: WatchStatsSummary) -> Int {
        switch tier {
        case .level1: return s.level1Days
        case .level2: return s.level2Days
        case .level3: return s.level3Days
        case .level4: return s.level4Days
        }
    }

    private func formatted(_ value: Int) -> String {
        value >= 1000 ? String(format: "%.1fk", Double(value) / 1000) : "\(value)"
    }
}
