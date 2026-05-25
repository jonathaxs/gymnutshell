// ⌘
//  GymNutshellWidget/LargeGoalsWidget.swift
//
//  Propósito: Widget systemLarge "Metas", lista das metas ativas com barras
//             de progresso individuais. Compartilha o WidgetSnapshot escrito
//             pelo app principal.
// ⌘

import WidgetKit
import SwiftUI
import GymNutshellCore

// MARK: - Widget

struct GymNutshellGoalsWidget: Widget {
    let kind: String = "GymNutshellGoalsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LargeWidgetProvider()) { entry in
            GoalsLargeView(snapshot: entry.snapshot)
                .widgetURL(URL(string: "gymnutshell://today"))
                .containerBackground(for: .widget) {
                    largeWidgetBackground(for: entry.snapshot)
                }
        }
        .configurationDisplayName("Metas")
        .description("Progresso individual das suas metas ativas.")
        .supportedFamilies([.systemLarge])
    }
}

private struct GoalsLargeView: View {
    let snapshot: WidgetSnapshot

    private var fg: Color { largeWidgetTextColor(for: snapshot) }

    /// Mostra até 6 metas, cabe sem corte vertical com o header acima.
    private var visibleGoals: [GoalProgress] {
        Array(snapshot.goals.prefix(6))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            LargeHeader(snapshot: snapshot, textColor: fg)

            VStack(spacing: 10) {
                ForEach(visibleGoals) { goal in
                    GoalRow(goal: goal, textColor: fg)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
    }
}

private struct GoalRow: View {
    let goal: GoalProgress
    let textColor: Color

    private var barColor: Color {
        widgetRingColor(progress: Double(goal.percent) / 100.0)
    }

    /// Mesma regra do anel: em fundos customizados (accent/custom) a barra ganha
    /// borda na cor do texto pra contrastar com gradients da mesma família.
    private var needsBorder: Bool {
        WidgetBackgroundStore.loadMode() != .system
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(goal.emoji)
                .font(.system(size: 16))
                .frame(width: 22)
                .accessibilityHidden(true)
            Text(goal.label)
                .font(.caption.weight(.medium))
                .foregroundStyle(textColor)
                .lineLimit(1)
                .frame(width: 70, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.25))
                    Capsule()
                        .fill(barColor)
                        .frame(width: geo.size.width * CGFloat(min(1.0, Double(goal.percent) / 100.0)))
                }
                .overlay {
                    if needsBorder {
                        Capsule().stroke(textColor, lineWidth: 1)
                    }
                }
            }
            .frame(height: 10)

            Text("\(goal.percent)%")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(textColor)
                .frame(width: 38, alignment: .trailing)
        }
        // Cada meta = 1 elemento focável: "Água, 60 por cento concluído".
        .accessibilityElement(children: .combine)
        .accessibilityLabel(goal.label)
        .accessibilityValue(A11y.progressValue(percent: goal.percent))
    }
}

// MARK: - Preview

#Preview(as: .systemLarge) {
    GymNutshellGoalsWidget()
} timeline: {
    GymNutshellWidgetEntry(date: .now, snapshot: .placeholder)
}
