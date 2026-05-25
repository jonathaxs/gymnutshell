// ⌘
//  GymNutshellCore/Models/WidgetBackground.swift
//
//  Propósito: Cor de fundo personalizada pros widgets do iPhone (Small e Medium).
//             Armazena RGBA via App Group UserDefaults pro widget extension ler.
//             Expõe um LinearGradient estilo iOS pra usar como containerBackground.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-05-12.
// ⌘

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Cor personalizada do fundo dos widgets. RGBA é a representação serializável;
/// o gradiente é computado pra dar profundidade estilo iOS (top-leading mais claro,
/// bottom-trailing mais escuro).
public struct WidgetBackground: Codable, Sendable, Equatable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    /// Constrói um gradiente a partir de qualquer SwiftUI.Color, extraindo RGBA via UIColor.
    /// Útil pro widget gerar o fundo a partir da AppAccentColor sem precisar persistir RGBA.
    #if canImport(UIKit)
    public static func gradient(from color: Color) -> LinearGradient {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return WidgetBackground(
            red: Double(r),
            green: Double(g),
            blue: Double(b),
            alpha: Double(a)
        ).gradient
    }
    #endif

    /// Cor de texto que contrasta com a cor base, branco em fundos escuros,
    /// preto em fundos claros. Usa luminância perceptual (Rec. 601).
    /// Threshold 0.6 favorece branco; só vira preto quando o fundo é bem claro.
    public var contrastingForegroundColor: Color {
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.6 ? .black : .white
    }

    /// Versão estática pra calcular contraste a partir de qualquer SwiftUI.Color.
    /// Usada quando o fundo vem da AppAccentColor (não há RGBA persistido).
    #if canImport(UIKit)
    public static func contrastingForegroundColor(for color: Color) -> Color {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return WidgetBackground(
            red: Double(r),
            green: Double(g),
            blue: Double(b),
            alpha: Double(a)
        ).contrastingForegroundColor
    }
    #endif

    /// Top-leading: cor base misturada com branco (mais clara).
    /// Bottom-trailing: cor base multiplicada (mais escura).
    /// Mistura RGB direta evita depender de UIColor, mantém o modelo multiplataforma.
    public var gradient: LinearGradient {
        let lightFactor = 0.18
        let darkFactor = 0.30
        let lighter = Color(
            red: red + (1 - red) * lightFactor,
            green: green + (1 - green) * lightFactor,
            blue: blue + (1 - blue) * lightFactor,
            opacity: alpha
        )
        let darker = Color(
            red: red * (1 - darkFactor),
            green: green * (1 - darkFactor),
            blue: blue * (1 - darkFactor),
            opacity: alpha
        )
        return LinearGradient(
            colors: [lighter, darker],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
