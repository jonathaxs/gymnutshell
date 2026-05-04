// ⌘
//  GymNutshell/GymNutshellApp/Views/ProfileView/Components/ProfileRecentActivityView.swift
//
//  Propósito: Grade "Últimos 7 dias" — mostra o emoji do nível (ou um ponto) pra cada um
//             dos últimos 7 dias do calendário. Tocar num dia dispara o callback onDayTap pra
//             que a ProfileView possa navegar até aquela data na AchievementsView.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-28.
// ⌘

import SwiftUI
import GymNutshellCore

/// Grade de atividade de sete dias com emoji por dia, número da data e inicial do dia da semana.
struct ProfileRecentActivityView: View {

    let entries: [(date: Date, record: DailyRecord?)]
    let selectedTheme: AppTheme
    let onDayTap: (Date) -> Void

    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color { (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "profile.recent.section", bundle: .gymNutshellCore))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            // Células dos sete dias — tocar navega pra aquele dia na AchievementsView.
            HStack(spacing: 6) {
                ForEach(entries, id: \.date) { entry in
                    Button {
                        onDayTap(entry.date)
                    } label: {
                        dayCell(entry: entry)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func dayCell(entry: (date: Date, record: DailyRecord?)) -> some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(entry.date)
        let hasRecord = entry.record != nil && entry.record!.percent > 0
        let dayNumber = calendar.component(.day, from: entry.date)

        return VStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(hasRecord
                          ? accentColor.opacity(0.15)
                          : Color(.tertiarySystemBackground))
                    .frame(width: 36, height: 36)
                    .overlay {
                        if isToday {
                            Circle().stroke(accentColor, lineWidth: 1.5)
                        }
                    }
                Text(entry.record.map { selectedTheme.emoji(for: DailyAchievement.from(emoji: $0.achievementEmoji)) } ?? "·")
                    .font(.system(size: entry.record != nil ? 18 : 14))
            }
            Text("\(dayNumber)")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isToday ? accentColor : .primary)
            Text(weekdayInitial(for: entry.date))
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }

    // Símbolo do dia da semana em uma letra só, respeitando o locale (ex: "S", "T").
    private func weekdayInitial(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }
}
