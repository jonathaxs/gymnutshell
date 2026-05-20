// ⌘
//  GymNutshellCore/Sources/GymNutshellCore/UI/View+TapButton.swift
//
//  Propósito: Modifier que combina `onTapGesture` com a trait `.isButton`
//             pra VoiceOver, usado em cards e linhas tappáveis que não são
//             `Button` nativo.
// ⌘

import SwiftUI

public extension View {
    /// Aplica `onTapGesture` e marca o elemento como botão pra VoiceOver.
    /// Use em áreas tappáveis que não são `Button` (ex.: cards inteiros, rows).
    func tapButton(perform action: @escaping () -> Void) -> some View {
        self
            .onTapGesture(perform: action)
            .accessibilityAddTraits(.isButton)
    }
}
