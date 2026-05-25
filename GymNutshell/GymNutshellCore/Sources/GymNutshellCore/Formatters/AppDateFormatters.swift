// ⌘
//  GymNutshellCore/Sources/GymNutshellCore/Formatters/AppDateFormatters.swift
//
//  Propósito: Formatters de data reutilizáveis, cacheados como `static let`
//             pra evitar realocação por chamada em listas/widgets.
// ⌘

import Foundation

/// Formatters de data compartilhados entre App, Watch e Widgets.
/// Cada `static let` é instanciado uma vez por processo.
public enum AppDateFormatters {

    /// Chave estável de dia no formato `yyyy-MM-dd`. Independente de locale
    /// (usa `en_US_POSIX`) pra servir como ID determinístico em mapas/persistência.
    public static let dayKey: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// Inicial do dia da semana (1 letra), "S", "M", etc. Locale do sistema.
    public static let weekdayInitial: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEEE"
        return f
    }()

    /// Data em estilo medium localizado, ex.: "May 16, 2026" / "16 de mai. de 2026".
    public static let mediumDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    /// Mês e ano localizado em forma standalone, ex.: "May 2026" / "Maio 2026".
    /// Usa `LLLL` (standalone) em vez de `MMMM` pra capitalização correta em
    /// idiomas como pt-BR sem precisar de `.capitalized` manual.
    public static let monthYear: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f
    }()

    /// Data por extenso pra leitura visual ("Sábado, 16 de maio").
    /// Usa template localizado `EEEEMMMMd` e capitaliza a primeira letra.
    public static func longDate(for date: Date, locale: Locale = .current) -> String {
        let f = DateFormatter()
        f.locale = locale
        f.setLocalizedDateFormatFromTemplate("EEEEMMMMd")
        let s = f.string(from: date)
        return s.isEmpty ? s : s.prefix(1).uppercased() + s.dropFirst()
    }
}
