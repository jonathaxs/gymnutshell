// ⌘
//  GymNutshell/GymNutshellApp/Views/WelcomeView/WelcomeComponents.swift
//
//  Propósito: Componentes de UI reutilizáveis compartilhados entre as etapas da WelcomeView.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-10.
// ⌘

import SwiftUI

// MARK: - WelcomeStepHeader

/// Exibe o emoji, título e subtítulo no topo de cada etapa de onboarding.
/// Todas as etapas usam o mesmo layout visual, então isso evita repetição.
struct WelcomeStepHeader: View {

    let emoji: String
    let title: String
    var subtitle: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                Text(emoji)
                    .font(.system(size: 44))
                    // Decorativo — o título logo ao lado já comunica a etapa.
                    .accessibilityHidden(true)
                Text(title)
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)
            }
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 16)
    }
}

// MARK: - WelcomeField

/// Campo de texto com label e estilo consistente usado nas etapas de formulário do onboarding.
/// Aceita tipo de teclado, autocapitalização e binding externo de foco opcionais.
/// O binding de foco externo (Binding<Bool>) permite que o chamador controle
/// programaticamente o foco sem acesso direto ao @FocusState interno.
struct WelcomeField: View {

    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words
    /// Binding externo para controle de foco — mantido em sincronia com o @FocusState interno.
    var externalFocus: Binding<Bool>? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .focused($isFocused)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                // O Text("label") acima fica visível, mas é melhor o VoiceOver
                // anunciar o nome do campo junto do conteúdo focado — sem isso
                // só o placeholder é lido.
                .accessibilityLabel(label)
        }
        // Sincroniza: foco do TextField → binding externo.
        .onChange(of: isFocused) { _, newValue in
            externalFocus?.wrappedValue = newValue
        }
        // Sincroniza: binding externo → foco do TextField (Next/Done programático).
        .onChange(of: externalFocus?.wrappedValue ?? false) { _, newValue in
            guard externalFocus != nil, isFocused != newValue else { return }
            isFocused = newValue
        }
    }
}
