// ⌘
//  GymNutshellWidget/GymNutshellLargeWidgets.swift
//
//  Propósito: Widget systemLarge "Calendário", grade de até 6 semanas com cor
//             por dia (mesma escala do anel) e header de tier/progresso.
//             Infra compartilhada (Provider, helpers, ring, header) está em
//             LargeWidgetShared.swift. Widget "Metas" está em LargeGoalsWidget.swift.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-05-15.
// ⌘

import WidgetKit
import SwiftUI
import GymNutshellCore

// MARK: - Widget

struct GymNutshellCalendarWidget: Widget {
    let kind: String = "GymNutshellCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LargeWidgetProvider()) { entry in
            CalendarLargeView(snapshot: entry.snapshot)
                .containerBackground(for: .widget) {
                    largeWidgetBackground(for: entry.snapshot)
                }
        }
        .configurationDisplayName("Calendário")
        .description("Progresso do dia e janela dos últimos 35 dias.")
        .supportedFamilies([.systemLarge])
    }
}

private struct CalendarLargeView: View {
    let snapshot: WidgetSnapshot

    private var fg: Color { largeWidgetTextColor(for: snapshot) }

    /// Grade do mês atual alinhada ao `firstWeekday` do calendário do sistema.
    /// Inclui células "fora do mês" (do mês anterior/posterior) pra preencher
    /// a primeira e última linha, renderizadas em transparente pra dar a forma
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

                    // Cabeçalho de dias da semana, decorativo, ocultado pra não falar
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
    /// False pra células de preenchimento (mês anterior/posterior), renderizadas vazias.
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
        // Células fora do mês são decorativas, ocultadas pra reduzir ruído.
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

// MARK: - Preview

#Preview(as: .systemLarge) {
    GymNutshellCalendarWidget()
} timeline: {
    GymNutshellWidgetEntry(date: .now, snapshot: .placeholder)
}
