// ⌘
//  GymNutshellWidget/GymNutshellWidget.swift
//
//  Propósito: Widget para iPhone (Small e Medium) — mostra o anel de progresso do dia
//             e o tier atual. Lê o WidgetSnapshot escrito pelo app principal via App Group.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-29.
// ⌘

import WidgetKit
import SwiftUI
import GymNutshellCore

// MARK: - Entry + Provider

struct GymNutshellWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct GymNutshellWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> GymNutshellWidgetEntry {
        GymNutshellWidgetEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (GymNutshellWidgetEntry) -> Void) {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        completion(GymNutshellWidgetEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GymNutshellWidgetEntry>) -> Void) {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        // Cria entradas a cada 15min nas próximas 4h. O iOS prioriza reloads de
        // widgets vistos com frequência, e múltiplas entradas dão dicas de cadência.
        // Reloads imediatos ao mudar intake continuam vindo de WidgetCenter.reloadAllTimelines().
        let now = Date()
        var entries: [GymNutshellWidgetEntry] = []
        for i in 0..<16 {
            let date = now.addingTimeInterval(TimeInterval(i * 15 * 60))
            entries.append(GymNutshellWidgetEntry(date: date, snapshot: snapshot))
        }
        let nextRefresh = now.addingTimeInterval(15 * 60)
        completion(Timeline(entries: entries, policy: .after(nextRefresh)))
    }
}

// MARK: - Widget definition

struct GymNutshellWidget: Widget {
    let kind: String = "GymNutshellWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GymNutshellWidgetProvider()) { entry in
            GymNutshellWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Gym Nutshell")
        .description("Acompanhe seu progresso diário.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Views

struct GymNutshellWidgetEntryView: View {
    let entry: GymNutshellWidgetEntry
    @Environment(\.widgetFamily) private var family

    private var accent: Color {
        AppAccentColor(rawValue: entry.snapshot.accentColorRaw)?.color ?? .blue
    }

    /// Pontos por tier — espelha `DailyAchievement.points`.
    private var tierPoints: Int {
        switch entry.snapshot.tier {
        case 2:  return 40
        case 3:  return 60
        case 4:  return 90
        default: return 0
        }
    }

    /// Cor do anel acompanha o progresso, mesma regra do Watch e da TodayView:
    /// <30% vermelho, <60% laranja, <100% verde, 100% azul.
    private var ringColor: Color {
        switch entry.snapshot.progressNormalized {
        case ..<0.30: return .red
        case ..<0.60: return .orange
        case ..<1.0:  return .green
        default:      return .blue
        }
    }

    var body: some View {
        switch family {
        case .systemMedium: mediumView
        default: smallView
        }
    }

    // MARK: Small

    private var smallView: some View {
        VStack(spacing: 0) {
            Text(entry.snapshot.tierName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 10)

            Text(entry.snapshot.tierEmoji)
                .font(.system(size: 60))
                .minimumScaleFactor(0.6)

            Spacer(minLength: 10)

            Text("\(entry.snapshot.progressPercent)%")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(ringColor)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
    }

    // MARK: Medium

    private var mediumView: some View {
        HStack(spacing: 16) {
            ProgressRingView(
                progress: entry.snapshot.progressNormalized,
                emoji: entry.snapshot.tierEmoji,
                accentColor: ringColor,
                lineWidth: 10,
                emojiSize: 28
            )
            .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.snapshot.tierName)
                    .font(.headline)
                    .lineLimit(1)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(entry.snapshot.progressPercent)%")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(accent)
                        .minimumScaleFactor(0.8)
                    Text("— \(tierPoints) pts")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(entry.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - Componente compartilhado: anel de progresso

private struct ProgressRingView: View {
    let progress: Double
    let emoji: String
    let accentColor: Color
    let lineWidth: CGFloat
    let emojiSize: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.3), value: progress)
            Text(emoji)
                .font(.system(size: emojiSize))
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    GymNutshellWidget()
} timeline: {
    GymNutshellWidgetEntry(date: .now, snapshot: .placeholder)
}

#Preview(as: .systemMedium) {
    GymNutshellWidget()
} timeline: {
    GymNutshellWidgetEntry(date: .now, snapshot: .placeholder)
}
