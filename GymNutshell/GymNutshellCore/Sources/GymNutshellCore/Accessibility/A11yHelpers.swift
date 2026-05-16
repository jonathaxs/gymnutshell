// ⌘
//  GymNutshellCore/Accessibility/A11yHelpers.swift
//
//  Propósito: Helpers centralizados para construir strings de VoiceOver
//             (labels, values, hints) reaproveitáveis em todos os targets
//             — iPhone app, Watch app e widgets. Toda a montagem fica aqui
//             pra que mudar a frase de "faixa verde" não exija varrer dezenas
//             de views.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-05-16.
// ⌘

import Foundation

// MARK: - Faixa de progresso (cor → texto)

/// Mapeia o progresso normalizado em uma das quatro faixas de cor usadas no app
/// (vermelho/laranja/verde/azul) e devolve a frase localizada equivalente.
/// Para usuários de VoiceOver, esta string substitui o sinal visual da cor.
public enum A11yProgressBand: Sendable {
    case red, orange, green, blue

    /// Classifica o progresso usando exatamente a mesma regra do anel visual
    /// (TodayProgressRingView, widgets, Watch): <30%, <60%, <100%, =100%.
    public static func from(progress: Double) -> A11yProgressBand {
        switch progress {
        case ..<0.30: return .red
        case ..<0.60: return .orange
        case ..<1.0:  return .green
        default:      return .blue
        }
    }

    /// Frase localizada que descreve a faixa — inclui sinal de estado.
    /// Ex.: "faixa verde, próximo do objetivo".
    public var localizedDescription: String {
        let key: String
        switch self {
        case .red:    key = "a11y.band.red"
        case .orange: key = "a11y.band.orange"
        case .green:  key = "a11y.band.green"
        case .blue:   key = "a11y.band.blue"
        }
        return String(localized: String.LocalizationValue(key), bundle: .gymNutshellCore)
    }
}

// MARK: - Builders de strings de VoiceOver

/// Conjunto de funções estáticas que montam frases prontas para VoiceOver,
/// já localizadas. Nenhuma view deve concatenar manualmente: sempre chamar
/// um destes helpers.
public enum A11y {

    /// "65 por cento" / "65 percent".
    public static func percent(_ percent: Int) -> String {
        let fmt = String(localized: "a11y.percent.format", bundle: .gymNutshellCore)
        return String(format: fmt, percent)
    }

    /// Value pronto para um anel/barra: "65 por cento, faixa verde, próximo do objetivo".
    public static func progressValue(percent: Int) -> String {
        let band = A11yProgressBand.from(progress: Double(percent) / 100.0).localizedDescription
        let fmt = String(localized: "a11y.progress.value.format", bundle: .gymNutshellCore)
        return String(format: fmt, percent, band)
    }

    /// Value pronto para um row de meta de tracking: "30 de 100 g, 30 por cento, faixa vermelha…".
    public static func goalRowValue(current: Int, goal: Int, unit: String, percent: Int) -> String {
        let band = A11yProgressBand.from(progress: Double(percent) / 100.0).localizedDescription
        let fmt = String(localized: "a11y.goalrow.value.format", bundle: .gymNutshellCore)
        return String(format: fmt, current, goal, unit, percent, band)
    }

    /// Value para um row de meta em dia de descanso. Não tem percentual nem faixa
    /// — o estado em si já comunica que a meta está cumprida.
    public static func goalRowRestDayValue() -> String {
        String(localized: "a11y.goalrow.value.restday", bundle: .gymNutshellCore)
    }

    /// Value para uma célula de calendário (MonthlyCalendarView, widget Calendar).
    /// Combina data por extenso + estado (hoje, futuro, sem registro, com percentual + faixa).
    public static func dayCellValue(date: Date,
                                    percent: Int?,
                                    isToday: Bool,
                                    isFuture: Bool,
                                    isSelected: Bool) -> String {
        let dateString = Self.spokenDate(for: date)

        let core: String
        if isFuture && !isToday {
            let fmt = String(localized: "a11y.daycell.future.format", bundle: .gymNutshellCore)
            core = String(format: fmt, dateString)
        } else if let p = percent, p > 0 {
            let band = A11yProgressBand.from(progress: Double(p) / 100.0).localizedDescription
            let key: String = isToday ? "a11y.daycell.today.format" : "a11y.daycell.past.format"
            let fmt = String(localized: String.LocalizationValue(key), bundle: .gymNutshellCore)
            core = isToday
                ? String(format: fmt, dateString, p, band)
                : String(format: fmt, dateString, p, band)
        } else {
            // sem dados — passado sem registro ou hoje ainda zerado
            let key: String = isToday ? "a11y.daycell.today.empty.format" : "a11y.daycell.empty.format"
            let fmt = String(localized: String.LocalizationValue(key), bundle: .gymNutshellCore)
            core = String(format: fmt, dateString)
        }

        if isSelected {
            return core + String(localized: "a11y.daycell.selected.suffix", bundle: .gymNutshellCore)
        }
        return core
    }

    /// Data falada por extenso (ex.: "sábado, 16 de maio") — sem ano por padrão
    /// para reduzir verbosidade dentro de grids. Respeita a localização do bundle.
    public static func spokenDate(for date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: Bundle.gymNutshellCore.preferredLocalizations.first ?? "en")
        df.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        return df.string(from: date)
    }

    /// Hint para botões de incremento/decremento (Watch ±).
    public static func incrementHint() -> String {
        String(localized: "a11y.hint.increment", bundle: .gymNutshellCore)
    }

    public static func decrementHint() -> String {
        String(localized: "a11y.hint.decrement", bundle: .gymNutshellCore)
    }

    /// Hint do botão OFF/ON de rest day. `currentlyOn` reflete o estado atual.
    public static func restDayToggleHint(currentlyOn: Bool) -> String {
        let key = currentlyOn ? "a11y.hint.restday.deactivate" : "a11y.hint.restday.activate"
        return String(localized: String.LocalizationValue(key), bundle: .gymNutshellCore)
    }

    /// Label do botão de rest day — espelha o estado atual.
    public static func restDayToggleLabel(currentlyOn: Bool) -> String {
        let key = currentlyOn ? "a11y.label.restday.on" : "a11y.label.restday.off"
        return String(localized: String.LocalizationValue(key), bundle: .gymNutshellCore)
    }
}
