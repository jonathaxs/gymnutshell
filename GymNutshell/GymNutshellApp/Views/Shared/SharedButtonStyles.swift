// ⌘
//  GymNutshell/GymNutshellApp/Views/Shared/SharedButtonStyles.swift
//
//  Propósito: Estilos de botão reutilizáveis e modificador de press-scale usados em todo o app.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-28.
// ⌘

import SwiftUI

// MARK: - PressScaleButtonStyle

/// Um estilo de botão que diminui levemente ao pressionar, dando feedback tátil.
/// Usado pra elementos interativos dentro da lista de Achievements (ex: botão de editar).
struct PressScaleButtonStyle: ButtonStyle {
    private static let pressedScale: CGFloat = 0.92
    private static let springResponse: Double = 0.22
    private static let springDamping: Double = 0.65

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? Self.pressedScale : 1.0)
            .animation(
                .spring(response: Self.springResponse, dampingFraction: Self.springDamping),
                value: configuration.isPressed
            )
    }
}

// MARK: - PressScaleModifier

// Aumenta a escala da view ao pressionar e volta com spring ao soltar.
// Usa @GestureState pra o scale resetar automaticamente se o gesto for cancelado.
struct PressScaleModifier: ViewModifier {

    var pressedScale: CGFloat = 1.15
    var response: Double = 0.25
    var dampingFraction: Double = 0.40

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    @GestureState private var isPressed: Bool = false

    func body(content: Content) -> some View {
        let scale: CGFloat = (reduceMotion || !isEnabled) ? 1.0 : (isPressed ? pressedScale : 1.0)

        content
            .scaleEffect(scale)
            .animation(
                reduceMotion ? nil : .spring(response: response, dampingFraction: dampingFraction),
                value: isPressed
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
    }
}

// MARK: - Extensão de View

// Atalho conveniente pra os chamadores escreverem .pressScale(...) em vez de .modifier(...).
extension View {
    func pressScale(
        _ scale: CGFloat = 1.15,
        response: Double = 0.25,
        dampingFraction: Double = 0.40
    ) -> some View {
        modifier(PressScaleModifier(
            pressedScale: scale,
            response: response,
            dampingFraction: dampingFraction
        ))
    }
}
