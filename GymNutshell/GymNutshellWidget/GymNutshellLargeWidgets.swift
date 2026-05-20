// ⌘
//  GymNutshellWidget/GymNutshellLargeWidgets.swift
//
//  Propósito: Widgets systemLarge — variantes "Calendário" (grade de 5 semanas
//             com cor por dia) e "Metas" (lista das metas ativas com barras).
//             Compartilham o WidgetSnapshot escrito pelo app principal.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-05-15.
// ⌘

import WidgetKit
import SwiftUI
import GymNutshellCore

// MARK: - Provider compartilhado

private struct LargeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> GymNutshellWidgetEntry {
        GymNutshellWidgetEntry(date: Date(), snapshot: .placeholder)
    }
    func getSnapshot(in context: Context, completion: @escaping (GymNutshellWidgetEntry) -> Void) {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        completion(GymNutshellWidgetEntry(date: Date(), snapshot: snapshot))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<GymNutshellWidgetEntry>) -> Void) {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
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

// MARK: - Helpers de visual compartilhados pelos dois widgets

private func textColor(for snapshot: WidgetSnapshot) -> Color {
    switch WidgetBackgroundStore.loadMode() {
    case .accent:
        let accent = AppAccentColor(rawValue: snapshot.accentColorRaw)?.color ?? .blue
        return WidgetBackground.contrastingForegroundColor(for: accent)
    case .custom:
        if let bg = WidgetBackgroundStore.loadCustomColor() {
            return bg.contrastingForegroundColor
        }
        return .primary
    case .system:
        return .primary
    }
}

@ViewBuilder
private func largeBackground(for snapshot: WidgetSnapshot) -> some View {
    switch WidgetBackgroundStore.loadMode() {
    case .accent:
        let accent = AppAccentColor(rawValue: snapshot.accentColorRaw)?.color ?? .blue
        WidgetBackground.gradient(from: accent)
    case .custom:
        if let bg = WidgetBackgroundStore.loadCustomColor() {
            bg.gradient
        } else {
            Rectangle().fill(.fill.tertiary)
        }
    case .system:
        Rectangle().fill(.fill.tertiary)
    }
}

/// True quando o widget está usando fundo customizado (accent ou custom).
private var hasCustomBackground: Bool {
    WidgetBackgroundStore.loadMode() != .system
}

// MARK: - Ring grande reutilizável

private struct LargeRing: View {
    let progress: Double
    let emoji: String
    let borderColor: Color?

    var body: some View {
        ZStack {
            if let borderColor {
                Circle().stroke(borderColor, lineWidth: 14)
            }
            Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 12)
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(widgetRingColor(progress: progress),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.3), value: progress)
            Text(emoji).font(.system(size: 36))
        }
    }
}

// MARK: - Header compartilhado (tier + %)

private struct LargeHeader: View {
    let snapshot: WidgetSnapshot
    let textColor: Color

    private var tierPoints: Int {
        switch snapshot.tier {
        case 2: return 40
        case 3: return 60
        case 4: return 90
        default: return 0
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            LargeRing(
                progress: snapshot.progressNormalized,
                emoji: snapshot.tierEmoji,
                borderColor: hasCustomBackground ? textColor : nil
            )
            .frame(width: 86, height: 86)

            VStack(alignment: .leading, spacing: 2) {
                Text(snapshot.updatedAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(textColor)
                Text(snapshot.tierName)
                    .font(.headline)
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(snapshot.progressPercent)%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(textColor)
                    Text("— \(tierPoints) pts")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(textColor)
                }
            }
            Spacer(minLength: 0)
        }
        // Header inteiro vira 1 elemento: "Today, Big Cat, 65 percent, 60 points".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: String(localized: "a11y.widget.large.header.format",
                                                 bundle: .gymNutshellCore),
                                   snapshot.updatedAt.formatted(date: .abbreviated, time: .omitted),
                                   snapshot.tierName,
                                   snapshot.progressPercent,
                                   tierPoints))
    }
}

// MARK: - Calendar widget

struct GymNutshellCalendarWidget: Widget {
    let kind: String = "GymNutshellCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LargeWidgetProvider()) { entry in
            CalendarLargeView(snapshot: entry.snapshot)
                .containerBackground(for: .widget) {
                    largeBackground(for: entry.snapshot)
                }
        }
        .configurationDisplayName("Calendário")
        .description("Progresso do dia e janela dos últimos 35 dias.")
        .supportedFamilies([.systemLarge])
    }
}

private struct CalendarLargeView: View {
    let snapshot: WidgetSnapshot

    private var fg: Color { textColor(for: snapshot) }

    /// Grade do mês atual alinhada ao `firstWeekday` do calendário do sistema.
    /// Inclui células "fora do mês" (do mês anterior/posterior) pra preencher
    /// a primeira e última linha — renderizadas em transparente pra dar a forma
    /// clássica de calendário sem confundir com dias do mês corrente.
    private var weeks: [[DayCellModel]] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        // Início do mês atual e quantos dias ele tem.
        let comps = cal.dateComponents([.year, .month], from: today)
        guard let firstOfMonth = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: firstOfMonth)
        else { return [] }

        // Coluna do primeiro dia do mês (0-based, respeitando firstWeekday).
        let firstWeekday = cal.component(.weekday, from: firstOfMonth)
        let leadingBlanks = ((firstWeekday - cal.firstWeekday) + 7) % 7

        // Tamanho total da grade arredondado pra múltiplo de 7 (4, 5 ou 6 linhas).
        let totalCells = Int(ceil(Double(leadingBlanks + range.count) / 7.0)) * 7

        var byDay: [Date: Int] = [:]
        for d in snapshot.recentDays {
            byDay[cal.startOfDay(for: d.date)] = d.percent
        }

        // gridStart = data da primeira célula (pode ser do mês anterior).
        guard let gridStart = cal.date(byAdding: .day, value: -leadingBlanks, to: firstOfMonth)
        else { return [] }

        var cells: [DayCellModel] = []
        for i in 0..<totalCells {
            guard let date = cal.date(byAdding: .day, value: i, to: gridStart) else { continue }
            let inMonth = cal.isDate(date, equalTo: firstOfMonth, toGranularity: .month)
            let isFuture = date > today
            cells.append(DayCellModel(
                date: date,
                percent: byDay[date] ?? 0,
                isFuture: isFuture,
                isToday: cal.isDate(date, inSameDayAs: today),
                hasData: byDay[date] != nil,
                inCurrentMonth: inMonth
            ))
        }
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0+7]) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header (data, tier, % e pts) → toca pra ir pra TodayView.
            Link(destination: URL(string: "gymnutshell://today")!) {
                LargeHeader(snapshot: snapshot, textColor: fg)
            }
            .buttonStyle(.plain)

            // Calendário → toca em qualquer lugar pra ir pra AchievementsView.
            Link(destination: URL(string: "gymnutshell://achievements")!) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(monthLabel())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(fg)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityLabel(String(format: String(localized: "a11y.widget.calendar.month.format",
                                                                 bundle: .gymNutshellCore), monthLabel()))

                    // Cabeçalho de dias da semana — decorativo, ocultado pra não falar
                    // "D, S, T, Q, Q, S, S" em swipe.
                    HStack(spacing: 4) {
                        ForEach(Array(weekdaySymbols().enumerated()), id: \.offset) { _, sym in
                            Text(sym)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(fg.opacity(0.7))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .accessibilityHidden(true)

                    VStack(spacing: 4) {
                        ForEach(Array(weeks.enumerated()), id: \.offset) { _, row in
                            HStack(spacing: 4) {
                                ForEach(Array(row.enumerated()), id: \.offset) { _, day in
                                    DayCell(day: day, textColor: fg)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
        .padding()
    }

    private func monthLabel() -> String {
        AppDateFormatters.monthYear.string(from: Date())
    }

    /// Abreviações curtas dos dias da semana respeitando o `firstWeekday` do calendário do sistema.
    private func weekdaySymbols() -> [String] {
        let cal = Calendar.current
        let symbols = cal.veryShortStandaloneWeekdaySymbols // ex pt-BR: ["D","S","T","Q","Q","S","S"]
        let first = cal.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }
}

/// Modelo de uma célula da grade. Encapsula o estado visual derivado do snapshot e do calendário.
private struct DayCellModel {
    let date: Date
    let percent: Int
    let isFuture: Bool
    let isToday: Bool
    let hasData: Bool
    /// False pra células de preenchimento (mês anterior/posterior) — renderizadas vazias.
    let inCurrentMonth: Bool
}

/// Célula de um dia: cor de fundo segue a escala do anel; número do dia visível;
/// borda fina em todas as células pra contrastar com gradients da mesma família;
/// hoje recebe uma borda mais grossa pra destaque.
private struct DayCell: View {
    let day: DayCellModel
    let textColor: Color

    private var fillColor: Color {
        if !day.inCurrentMonth { return Color.clear }
        if day.isFuture { return Color.secondary.opacity(0.08) }
        if !day.hasData || day.percent == 0 { return Color.secondary.opacity(0.20) }
        return widgetRingColor(progress: Double(day.percent) / 100.0)
    }

    private var numberColor: Color {
        if !day.inCurrentMonth { return textColor.opacity(0.25) }
        if day.isFuture { return textColor.opacity(0.45) }
        if !day.hasData || day.percent == 0 { return textColor.opacity(0.65) }
        return .white
    }

    private var dayNumber: String {
        String(Calendar.current.component(.day, from: day.date))
    }

    /// Mesma regra do anel/barras: só desenha borda em fundos custom (accent/custom),
    /// onde a cor da célula pode bater com a cor do gradient.
    /// Células fora do mês ficam sem borda pra não competir com o foco do mês atual.
    private var needsBorder: Bool {
        day.inCurrentMonth && WidgetBackgroundStore.loadMode() != .system
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(fillColor)
            if needsBorder {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(textColor.opacity(0.5), lineWidth: 0.8)
            }
            if day.isToday {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(textColor, lineWidth: 1.5)
            }
            Text(dayNumber)
                .font(.system(size: 10, weight: day.isToday ? .bold : .medium))
                .foregroundStyle(numberColor)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        // Células fora do mês são decorativas — ocultadas pra reduzir ruído.
        // Demais células viram elementos focáveis com data + estado.
        .accessibilityHidden(!day.inCurrentMonth)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(A11y.dayCellValue(date: day.date,
                                              percent: day.hasData ? day.percent : nil,
                                              isToday: day.isToday,
                                              isFuture: day.isFuture,
                                              isSelected: false))
    }
}

// MARK: - Goals widget

struct GymNutshellGoalsWidget: Widget {
    let kind: String = "GymNutshellGoalsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LargeWidgetProvider()) { entry in
            GoalsLargeView(snapshot: entry.snapshot)
                .widgetURL(URL(string: "gymnutshell://today"))
                .containerBackground(for: .widget) {
                    largeBackground(for: entry.snapshot)
                }
        }
        .configurationDisplayName("Metas")
        .description("Progresso individual das suas metas ativas.")
        .supportedFamilies([.systemLarge])
    }
}

private struct GoalsLargeView: View {
    let snapshot: WidgetSnapshot

    private var fg: Color { textColor(for: snapshot) }

    /// Mostra até 6 metas — cabe sem corte vertical com o header acima.
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

// MARK: - Previews

#Preview(as: .systemLarge) {
    GymNutshellCalendarWidget()
} timeline: {
    GymNutshellWidgetEntry(date: .now, snapshot: .placeholder)
}

#Preview(as: .systemLarge) {
    GymNutshellGoalsWidget()
} timeline: {
    GymNutshellWidgetEntry(date: .now, snapshot: .placeholder)
}
