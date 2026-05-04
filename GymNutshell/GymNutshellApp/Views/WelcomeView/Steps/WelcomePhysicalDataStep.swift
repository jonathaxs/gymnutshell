// ⌘
//  GymNutshell/GymNutshellApp/Views/WelcomeView/Steps/WelcomePhysicalDataStep.swift
//
//  Propósito: Etapa do onboarding — coleta os dados físicos do usuário
//             (peso, altura, idade e sexo) usados pra calcular as metas diárias.
//             Os campos se adaptam ao sistema de medidas detectado a partir do locale do device:
//               Métrico — kg (1 campo) + cm (1 campo)
//               US      — lbs (1 campo) + ft/in (2 campos)
//               UK      — stones + lbs (2 campos) + ft/in (2 campos)
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-10.
// ⌘

import SwiftUI
import GymNutshellCore

/// Etapa do onboarding: coleta métricas corporais necessárias pro GoalsCalculator.
/// Todos os campos numéricos são validados na WelcomeView antes de o usuário avançar.
struct WelcomePhysicalDataStep: View {

    let measurementSystem: MeasurementSystem

    @Binding var weightText: String         // kg (metric) ou lbs (US)
    @Binding var weightStonesText: String   // stones — só UK
    @Binding var weightStoneLbsText: String // lbs restante (0–13) — só UK
    @Binding var heightText: String         // cm — só metric
    @Binding var heightFeetText: String     // feet — US e UK
    @Binding var heightInchesText: String   // inches — US e UK
    @Binding var birthday: Date
    @Binding var sex: String
    var isWide: Bool = false
    var onContinue: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    var isFormValid: Bool = false
    var buttonColor: Color = .accentColor

    // Enumeração de campos focáveis — ordem de tab.
    private enum Field: Hashable {
        case weight, weightStones, weightStoneLbs, heightCm, heightFeet, heightInches
    }

    // Range válido pro DatePicker — de 120 anos atrás até a data de hoje.
    private var birthdayRange: ClosedRange<Date> {
        let now = Date()
        let minDate = Calendar.current.date(byAdding: .year, value: -120, to: now) ?? now
        return minDate...now
    }

    // @State em vez de @FocusState: focusedField atua como estado lógico apenas (não conectado
    // a nenhum .focused() direto). O foco real é controlado via externalFocus: em cada WelcomeField;
    // @FocusState sem .focused() não dispara re-render ao ser setado programaticamente, o que
    // quebrava o botão "Próximo"/"Concluído" da toolbar.
    @State private var focusedField: Field?

    // Converte o @FocusState<Field?> num Binding<Bool> por campo,
    // permitindo que WelcomeField aplique .focused() diretamente no TextField interno.
    private func focusBinding(for field: Field) -> Binding<Bool> {
        Binding(
            get: { focusedField == field },
            set: { isNowFocused in
                if isNowFocused {
                    focusedField = field
                } else if focusedField == field {
                    focusedField = nil
                }
            }
        )
    }

    // Próximo campo na sequência — depende do sistema de medidas.
    private var nextField: Field? {
        switch (measurementSystem, focusedField) {
        case (.metric, .weight):        return .heightCm
        case (.us, .weight):            return .heightFeet
        case (.us, .heightFeet):        return .heightInches
        case (.uk, .weightStones):      return .weightStoneLbs
        case (.uk, .weightStoneLbs):    return .heightFeet
        case (.uk, .heightFeet):        return .heightInches
        default:                        return nil
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    if !isWide {
                        WelcomeStepHeader(
                            emoji: "👤",
                            title: String(localized: "welcome.step.physical.title", bundle: .gymNutshellCore)
                        )
                    }

                    VStack(spacing: 16) {

                        // Seletor de sexo.
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: "welcome.field.sex", bundle: .gymNutshellCore))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Picker(String(localized: "welcome.field.sex", bundle: .gymNutshellCore), selection: $sex) {
                                Text(String(localized: "welcome.field.sex.female", bundle: .gymNutshellCore)).tag("female")
                                Text(String(localized: "welcome.field.sex.male", bundle: .gymNutshellCore)).tag("male")
                                Text(String(localized: "welcome.field.sex.other", bundle: .gymNutshellCore)).tag("other")
                            }
                            .pickerStyle(.segmented)
                        }

                        weightFields
                        heightFields

                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: "welcome.field.birthday", bundle: .gymNutshellCore))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            // O chip do .compact DatePicker tem padding interno próprio.
                            // Sem o Spacer e com leading-alignment, o chip cola na borda
                            // esquerda do container — alinhando com o texto dos TextFields acima.
                            DatePicker(
                                String(localized: "welcome.field.birthday", bundle: .gymNutshellCore),
                                selection: $birthday,
                                in: birthdayRange,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical)
                            .padding(.horizontal, 8)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Textos informativos abaixo do campo de Idade.
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "welcome.step.physical.info.calculate", bundle: .gymNutshellCore))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(localized: "welcome.step.physical.info.editable", bundle: .gymNutshellCore))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Botões inline — só no modo narrow (no wide ficam no painel contextual).
                        if !isWide, let onContinue, let onBack {
                            VStack(spacing: 8) {
                                Button(action: onContinue) {
                                    Text(String(localized: "welcome.button.continue", bundle: .gymNutshellCore))
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(buttonColor)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .disabled(!isFormValid)
                                .opacity(isFormValid ? 1.0 : 0.5)

                                Button(action: onBack) {
                                    Text(String(localized: "welcome.button.back", bundle: .gymNutshellCore))
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 8)
                        }
                    }

                    // Espaço extra ao final pra que o ScrollView tenha pra onde rolar
                    // quando o último campo é focado e o teclado + toolbar cobrem a área.
                    Color.clear.frame(height: 280)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: focusedField) { _, newField in
                guard let newField else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(newField, anchor: .center)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(nextField != nil
                               ? String(localized: "welcome.keyboard.next", bundle: .gymNutshellCore)
                               : String(localized: "welcome.keyboard.done", bundle: .gymNutshellCore)) {
                            focusedField = nextField
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    // MARK: - Campos de peso

    @ViewBuilder
    private var weightFields: some View {
        switch measurementSystem {
        case .metric:
            WelcomeField(
                label: String(localized: "welcome.field.weight", bundle: .gymNutshellCore),
                placeholder: String(localized: "welcome.field.weight.placeholder", bundle: .gymNutshellCore),
                text: $weightText,
                keyboard: .decimalPad,
                externalFocus: focusBinding(for: .weight)
            )
            .id(Field.weight)
        case .us:
            WelcomeField(
                label: String(localized: "welcome.field.weight.lbs", bundle: .gymNutshellCore),
                placeholder: String(localized: "welcome.field.weight.placeholder.lbs", bundle: .gymNutshellCore),
                text: $weightText,
                keyboard: .decimalPad,
                externalFocus: focusBinding(for: .weight)
            )
            .id(Field.weight)
        case .uk:
            // Peso UK usa dois campos: stones e lbs restante (0–13).
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "welcome.field.weight.uk", bundle: .gymNutshellCore))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    WelcomeField(
                        label: String(localized: "welcome.field.weight.stones", bundle: .gymNutshellCore),
                        placeholder: String(localized: "welcome.field.weight.stones.placeholder", bundle: .gymNutshellCore),
                        text: $weightStonesText,
                        keyboard: .numberPad,
                        externalFocus: focusBinding(for: .weightStones)
                    )
                    .id(Field.weightStones)
                    WelcomeField(
                        label: String(localized: "welcome.field.weight.stonelbs", bundle: .gymNutshellCore),
                        placeholder: String(localized: "welcome.field.weight.stonelbs.placeholder", bundle: .gymNutshellCore),
                        text: $weightStoneLbsText,
                        keyboard: .numberPad,
                        externalFocus: focusBinding(for: .weightStoneLbs)
                    )
                    .id(Field.weightStoneLbs)
                }
            }
        }
    }

    // MARK: - Campos de altura

    @ViewBuilder
    private var heightFields: some View {
        if measurementSystem == .metric {
            WelcomeField(
                label: String(localized: "welcome.field.height", bundle: .gymNutshellCore),
                placeholder: String(localized: "welcome.field.height.placeholder", bundle: .gymNutshellCore),
                text: $heightText,
                keyboard: .numberPad,
                externalFocus: focusBinding(for: .heightCm)
            )
            .id(Field.heightCm)
        } else {
            // US e UK usam feet + inches pra altura.
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "welcome.field.height.imperial", bundle: .gymNutshellCore))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    WelcomeField(
                        label: String(localized: "welcome.field.height.feet", bundle: .gymNutshellCore),
                        placeholder: String(localized: "welcome.field.height.feet.placeholder", bundle: .gymNutshellCore),
                        text: $heightFeetText,
                        keyboard: .numberPad,
                        externalFocus: focusBinding(for: .heightFeet)
                    )
                    .id(Field.heightFeet)
                    WelcomeField(
                        label: String(localized: "welcome.field.height.inches", bundle: .gymNutshellCore),
                        placeholder: String(localized: "welcome.field.height.inches.placeholder", bundle: .gymNutshellCore),
                        text: $heightInchesText,
                        keyboard: .numberPad,
                        externalFocus: focusBinding(for: .heightInches)
                    )
                    .id(Field.heightInches)
                }
            }
        }
    }
}
