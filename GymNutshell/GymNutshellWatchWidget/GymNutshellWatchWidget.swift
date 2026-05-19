// ⌘
//  GymNutshellWatchWidget/GymNutshellWatchWidget.swift
//
//  Propósito: Widget e complications pro Apple Watch — anel de progresso do dia,
//             nome da conquista atual e emoji do tier. Lê o WidgetSnapshot escrito
//             pelo Watch app (ou sincronizado do iPhone) via App Group.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-05-11.
// ⌘

import WidgetKit
import SwiftUI
import GymNutshellCore

// MARK: - Entry + Provider

struct GymNutshellWatchWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct GymNutshellWatchWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> GymNutshellWatchWidgetEntry {
        GymNutshellWatchWidgetEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (GymNutshellWatchWidgetEntry) -> Void) {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        completion(GymNutshellWatchWidgetEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GymNutshellWatchWidgetEntry>) -> Void) {
        // Reloads imediatos vêm via WidgetCenter.reloadAllTimelines() quando o Watch app
        // muda o intake ou recebe novo snapshot do iPhone. As entradas abaixo são só
        // dicas de cadência pro sistema priorizar refreshes.
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        let now = Date()
        var entries: [GymNutshellWatchWidgetEntry] = []
        for i in 0..<16 {
            let date = now.addingTimeInterval(TimeInterval(i * 15 * 60))
            entries.append(GymNutshellWatchWidgetEntry(date: date, snapshot: snapshot))
        }
        let nextRefresh = now.addingTimeInterval(15 * 60)
        completion(Timeline(entries: entries, policy: .after(nextRefresh)))
    }
}

// MARK: - Widget definition

struct GymNutshellWatchWidget: Widget {
    let kind: String = "GymNutshellWatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GymNutshellWatchWidgetProvider()) { entry in
            GymNutshellWatchWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Gym Nutshell")
        .description("Acompanhe seu progresso diário.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}

// MARK: - Views

struct GymNutshellWatchWidgetEntryView: View {
    let entry: GymNutshellWatchWidgetEntry
    @Environment(\.widgetFamily) private var family

    /// Cor do anel acompanha o tier do dia, mesma regra do TodayView no iPhone
    /// e do hero do Watch app: <30% vermelho, <60% laranja, <100% verde, 100% azul.
    private var ringColor: Color {
        switch entry.snapshot.progressNormalized {
        case ..<0.30: return .red
        case ..<0.60: return .orange
        case ..<1.0:  return .green
        default:      return .blue
        }
    }

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:    circularView
            case .accessoryRectangular: rectangularView
            case .accessoryCorner:      cornerView
            case .accessoryInline:      inlineView
            default:                    circularView
            }
        }
        // Cada família vira 1 elemento de a11y único — sem isso o usuário ouve
        // emoji, tier, "%" como elementos isolados em swipe na face do relógio.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: String(localized: "a11y.widget.summary.format",
                                                 bundle: .gymNutshellCore),
                                   entry.snapshot.tierName,
                                   entry.snapshot.progressPercent))
    }

    // MARK: Circular — anel com emoji no centro

    private var circularView: some View {
        ZStack {
            AccessoryRing(progress: entry.snapshot.progressNormalized, color: ringColor)
            Text(entry.snapshot.tierEmoji)
                .font(.system(size: 16))
                .minimumScaleFactor(0.7)
        }
        .padding(4)
        .widgetAccentable()
    }

    // MARK: Rectangular — anel ocupando a altura toda à esquerda; nome em cima e % embaixo à direita

    private var rectangularView: some View {
        HStack(spacing: 8) {
            ZStack {
                AccessoryRing(progress: entry.snapshot.progressNormalized, color: ringColor)
                Text(entry.snapshot.tierEmoji)
                    .font(.system(size: 22))
                    .minimumScaleFactor(0.5)
            }
            .padding(3)
            .aspectRatio(1, contentMode: .fit)
            .widgetAccentable()

            VStack(alignment: .leading, spacing: 0) {
                Text(entry.snapshot.tierName)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(entry.snapshot.progressPercent)%")
                    .font(.system(size: 20, weight: .bold))
                    .minimumScaleFactor(0.6)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: Corner — usado na quina de mostradores analógicos

    private var cornerView: some View {
        Text(entry.snapshot.tierEmoji)
            .font(.system(size: 18))
            .widgetLabel {
                ProgressView(
                    value: entry.snapshot.progressNormalized,
                    label: { Text("\(entry.snapshot.progressPercent)%") }
                )
                .tint(ringColor)
            }
    }

    // MARK: Inline — linha única de texto

    private var inlineView: some View {
        Text("\(entry.snapshot.tierEmoji) \(entry.snapshot.progressPercent)%")
    }
}

// MARK: - Anel reutilizável

private struct AccessoryRing: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.25), lineWidth: 4)
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.3), value: progress)
        }
    }
}

// MARK: - Preview

#Preview(as: .accessoryCircular) {
    GymNutshellWatchWidget()
} timeline: {
    GymNutshellWatchWidgetEntry(date: .now, snapshot: .placeholder)
}

#Preview(as: .accessoryRectangular) {
    GymNutshellWatchWidget()
} timeline: {
    GymNutshellWatchWidgetEntry(date: .now, snapshot: .placeholder)
}
