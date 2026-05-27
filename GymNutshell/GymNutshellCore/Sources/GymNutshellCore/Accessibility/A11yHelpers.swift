// ⌘
//  GymNutshellCore/Accessibility/A11yHelpers.swift
//
//  Propósito: Helpers centralizados para construir strings de VoiceOver
//             (labels, values, hints) reaproveitáveis em todos os targets
//            , iPhone app, Watch app e widgets. Toda a montagem fica aqui
//             pra que mudar a frase de "faixa verde" não exija varrer dezenas
//             de views.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-05-16.
// ⌘

import Foundation

// MARK: - Faixa de progresso (cor → texto)

/// Mapeia o progresso normalizado em uma das cinco faixas de cor usadas no app
/// (vermelho/laranja/verde/ciano/azul) e devolve a frase localizada equivalente.
/// Para usuários de VoiceOver, esta string substitui o sinal visual da cor.
public enum A11yProgressBand: Sendable {
    case red, orange, green, cyan, blue

    /// Classifica o progresso usando exatamente a mesma regra do anel visual
    /// (TodayProgressRingView, widgets, Watch): <33%, <66%, <90%, <100%, =100%.
    public static func from(progress: Double) -> A11yProgressBand {
        switch progress {
        case ..<0.33: return .red
        case ..<0.66: return .orange
        case ..<0.90: return .green
        case ..<1.0:  return .cyan
        default:      return .blue
        }
    }

    /// Frase localizada que descreve a faixa, inclui sinal de estado.
    /// Ex.: "faixa verde, indo muito bem".
    public var localizedDescription: String {
        let key: String
        switch self {
        case .red:    key = "a11y.band.red"
        case .orange: key = "a11y.band.orange"
        case .green:  key = "a11y.band.green"
        case .cyan:   key = "a11y.band.cyan"
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

    /// Value enxuto para um anel/barra: "65 por cento concluído".
    /// Faixa de cor é falada apenas no contexto do calendário, onde não há outro indicador.
    public static func progressValue(percent: Int) -> String {
        let fmt = String(localized: "a11y.progress.value.format", bundle: .gymNutshellCore)
        return String(format: fmt, percent)
    }

    /// Value para o header de um row de meta: "0 de 7h concluído".
    /// Não inclui percentual nem faixa pra não soar redundante quando o usuário
    /// percorre header + slider em sequência.
    public static func goalRowValue(current: Int, goal: Int, unit: String) -> String {
        let fmt = String(localized: "a11y.goalrow.value.format", bundle: .gymNutshellCore)
        return String(format: fmt, current, goal, unit)
    }

    /// Value para um row de meta em dia de descanso. Não tem percentual nem faixa
    /// o estado em si já comunica que a meta está cumprida.
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
            // sem dados, passado sem registro ou hoje ainda zerado
            let key: String = isToday ? "a11y.daycell.today.empty.format" : "a11y.daycell.empty.format"
            let fmt = String(localized: String.LocalizationValue(key), bundle: .gymNutshellCore)
            core = String(format: fmt, dateString)
        }

        if isSelected {
            return core + String(localized: "a11y.daycell.selected.suffix", bundle: .gymNutshellCore)
        }
        return core
    }

    /// Data falada por extenso (ex.: "sábado, 16 de maio"), sem ano por padrão
    /// para reduzir verbosidade dentro de grids. Respeita a localização do bundle.
    public static func spokenDate(for date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: Bundle.gymNutshellCore.preferredLocalizations.first ?? "en")
        df.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        return df.string(from: date)
    }

    /// Hint para botões de incremento/decremento (Watch).
    public static func incrementHint() -> String {
        String(localized: "a11y.hint.increment", bundle: .gymNutshellCore)
    }

    public static func decrementHint() -> String {
        String(localized: "a11y.hint.decrement", bundle: .gymNutshellCore)
    }

    /// Hint do botão OFF/ON de rest day. `currentlyOn` reflete o estado atual
    ///, quando true (descansando), tocar sai do modo; quando false, ativa.
    /// O label do botão é o próprio texto visível (ON/OFF), por isso esse
    /// helper devolve só o hint.
    public static func restDayToggleHint(currentlyOn: Bool) -> String {
        let key = currentlyOn ? "a11y.hint.restday.deactivate" : "a11y.hint.restday.activate"
        return String(localized: String.LocalizationValue(key), bundle: .gymNutshellCore)
    }

    /// Hint genérico "Toque para mais informações", usado em elementos
    /// tappáveis (ring, tier) que abrem uma sheet explicativa.
    public static func moreInfoHint() -> String {
        String(localized: "a11y.hint.more.info", bundle: .gymNutshellCore)
    }

    /// Label para um Slider de meta: "Controle deslizante Água" / "Water slider".
    public static func sliderLabel(for goalTitle: String) -> String {
        let fmt = String(localized: "a11y.slider.label.format", bundle: .gymNutshellCore)
        return String(format: fmt, goalTitle)
    }

    /// Label para um header colapsável de categoria: "Categoria Treino" / "Workout category".
    public static func categoryLabel(_ categoryName: String) -> String {
        let fmt = String(localized: "a11y.category.label.format", bundle: .gymNutshellCore)
        return String(format: fmt, categoryName)
    }

    public static func categoryHint() -> String {
        String(localized: "a11y.category.hint", bundle: .gymNutshellCore)
    }

    // MARK: - Calendário (AchievementsView)

    /// Value para uma célula do calendário de conquistas. Quando há registro do dia,
    /// `tierName` carrega o nome do tier (ex.: "Big Cat") ou o título do bônus
    /// (ex.: "Fitness Week"). Quando nil, fala "sem registro".
    public static func calendarDayValue(date: Date,
                                        tierName: String?,
                                        isToday: Bool,
                                        isFuture: Bool,
                                        isSelected: Bool) -> String {
        let dateString = Self.spokenDate(for: date)

        let core: String
        if isFuture && !isToday {
            let fmt = String(localized: "a11y.daycell.future.format", bundle: .gymNutshellCore)
            core = String(format: fmt, dateString)
        } else if let tierName, !tierName.isEmpty {
            let key: String = isToday
                ? "a11y.calendar.day.today.tier.format"
                : "a11y.calendar.day.tier.format"
            let fmt = String(localized: String.LocalizationValue(key), bundle: .gymNutshellCore)
            core = String(format: fmt, dateString, tierName)
        } else {
            let key: String = isToday ? "a11y.daycell.today.empty.format" : "a11y.daycell.empty.format"
            let fmt = String(localized: String.LocalizationValue(key), bundle: .gymNutshellCore)
            core = String(format: fmt, dateString)
        }

        if isSelected {
            return core + String(localized: "a11y.daycell.selected.suffix", bundle: .gymNutshellCore)
        }
        return core
    }
}
