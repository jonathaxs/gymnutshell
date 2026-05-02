// ⌘
//  GymNutshellCore/Services/StreakBonusChecker.swift
//
//  Propósito: Avalia todos os DailyRecords salvos pra determinar se o usuário
//             ganhou bônus de sequência semanal ou mensal, e insere os registros
//             de StreakBonus no SwiftData pros períodos elegíveis ainda não premiados.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-26.
// ⌘

import Foundation
import SwiftData

// MARK: - StreakBonusChecker

public struct StreakBonusChecker {

    public static func evaluateAndAward(into modelContext: ModelContext) {
        guard let allRecords = try? modelContext.fetch(FetchDescriptor<DailyRecord>()),
              let existingBonuses = try? modelContext.fetch(FetchDescriptor<StreakBonus>())
        else { return }

        let calendar = Calendar.current

        var recordsByDay: [Date: DailyRecord] = [:]
        for record in allRecords {
            let key = calendar.startOfDay(for: record.date)
            recordsByDay[key] = record
        }

        let awardedAnchors: Set<Date> = Set(
            existingBonuses.map { calendar.startOfDay(for: $0.anchorDate) }
        )

        // MARK: Verificação semanal

        let saturdays = recordsByDay.keys.filter {
            calendar.component(.weekday, from: $0) == 7
        }

        for saturday in saturdays {
            guard !awardedAnchors.contains(saturday) else { continue }
            guard let weekDays = weekRange(endingOn: saturday, calendar: calendar) else { continue }

            let weekRecords = weekDays.compactMap { recordsByDay[$0] }
            guard weekRecords.count == 7 else { continue }

            if allExpert(weekRecords) {
                modelContext.insert(StreakBonus(
                    anchorDate: saturday,
                    bonusType: "weekly.level4",
                    initialPoints: 800,
                    initialEmoji: "🪽"
                ))
                NotificationManager.shared.fireStreakBonus(emoji: "🪽", points: 800, typeKey: "weekly.level4", date: saturday)
            } else if allStrongOrExpert(weekRecords) {
                modelContext.insert(StreakBonus(
                    anchorDate: saturday,
                    bonusType: "weekly.level3",
                    initialPoints: 400,
                    initialEmoji: "✍️"
                ))
                NotificationManager.shared.fireStreakBonus(emoji: "✍️", points: 400, typeKey: "weekly.level3", date: saturday)
            }
        }

        // MARK: Verificação mensal

        let months = Set(allRecords.map {
            calendar.dateComponents([.year, .month], from: $0.date)
        })

        for components in months {
            guard let firstOfMonth = calendar.date(from: components),
                  let monthInterval = calendar.dateInterval(of: .month, for: firstOfMonth)
            else { continue }

            let lastDay = calendar.startOfDay(
                for: calendar.date(byAdding: .day, value: -1, to: monthInterval.end)!
            )

            guard !awardedAnchors.contains(lastDay) else { continue }

            let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)!.count

            var cursor = calendar.startOfDay(for: firstOfMonth)
            var monthRecords: [DailyRecord] = []
            for _ in 0..<daysInMonth {
                if let record = recordsByDay[cursor] {
                    monthRecords.append(record)
                }
                cursor = calendar.date(byAdding: .day, value: 1, to: cursor)!
            }

            guard monthRecords.count == daysInMonth else { continue }

            if allExpert(monthRecords) {
                modelContext.insert(StreakBonus(
                    anchorDate: lastDay,
                    bonusType: "monthly.level4",
                    initialPoints: 5000,
                    initialEmoji: "☠️"
                ))
                NotificationManager.shared.fireStreakBonus(emoji: "☠️", points: 5000, typeKey: "monthly.level4", date: lastDay)
            } else if allStrongOrExpert(monthRecords) {
                modelContext.insert(StreakBonus(
                    anchorDate: lastDay,
                    bonusType: "monthly.level3",
                    initialPoints: 2000,
                    initialEmoji: "🦾"
                ))
                NotificationManager.shared.fireStreakBonus(emoji: "🦾", points: 2000, typeKey: "monthly.level3", date: lastDay)
            }
        }
    }

    // MARK: - Helpers privados

    private static func allExpert(_ records: [DailyRecord]) -> Bool {
        records.allSatisfy { DailyAchievement.from(emoji: $0.achievementEmoji) == .level4 }
    }

    private static func allStrongOrExpert(_ records: [DailyRecord]) -> Bool {
        records.allSatisfy {
            let tier = DailyAchievement.from(emoji: $0.achievementEmoji)
            return tier == .level3 || tier == .level4
        }
    }

    private static func weekRange(endingOn saturday: Date, calendar: Calendar) -> [Date]? {
        guard let sunday = calendar.date(byAdding: .day, value: -6, to: saturday)
        else { return nil }

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: sunday)
        }
    }
}
