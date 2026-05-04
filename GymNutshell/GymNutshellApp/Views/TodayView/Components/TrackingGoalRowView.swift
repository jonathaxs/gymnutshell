// ⌘
//  GymNutshell/GymNutshellApp/Views/TodayView/Components/TrackingGoalRowView.swift
//
//  Propósito: Linha em estilo de card pras metas de rastreio (acumulação numérica).
//             Mostra um slider pra entrada. Os tons de cor refletem o nível de progresso.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-19.
// ⌘

import SwiftUI
import GymNutshellCore

// MARK: - TrackingGoalRowView

// Uma meta de rastreio: card com tint colorido pelo progresso e um slider.
// Cor muda de vermelho→laranja→verde→azul conforme o usuário se aproxima da meta diária.
struct TrackingGoalRowView: View {

    let emoji: String
    let title: String
    let unit: String
    let increment: Int
    let goal: Int
    @Binding var value: Int

    // Quando não-nil, exibe botão OFF/ON à esquerda do valor (usado por Musculação/Cardio).
    // ON = dia de descanso: slider é substituído por texto "Dia de descanso" e conta como meta cumprida.
    var isRestDay: Binding<Bool>? = nil

    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color { (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color }

    // MARK: - Valores derivados

    private var safeGoal: Int { max(goal, 0) }
    private var safeStep: Int { max(increment, 1) }

    private var clampedProgress: Double {
        guard safeGoal > 0 else { return 0 }
        return min(Double(value) / Double(safeGoal), 1)
    }

    // MARK: - Cores baseadas no progresso

    private var progressTint: Color {
        switch clampedProgress {
        case ..<0.30: return .red
        case ..<0.60: return .orange
        case ..<1.0:  return .green
        default:      return .blue
        }
    }

    // MARK: - Binding do slider

    // Faz a ponte entre o valor Int e o slider Double.
    // Encaixa nos passos de `increment`, limita em [0, goal], dispara haptic e anima.
    private var sliderBinding: Binding<Double> {
        Binding(
            get: { Double(value) },
            set: { newDouble in
                let snapped = Int((newDouble / Double(safeStep)).rounded()) * safeStep
                let clamped = min(max(snapped, 0), safeGoal)
                guard clamped != value else { return }
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation(.easeInOut(duration: 0.12)) {
                    value = clamped
                }
            }
        )
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Cabeçalho: emoji, nome, botão rest day (opcional) e texto atual/meta
            HStack(alignment: .center, spacing: 6) {
                Text(emoji)
                    .font(.headline)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .layoutPriority(1)
                Spacer(minLength: 6)
                Text("\(value) / \(safeGoal) \(unit)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if let rest = isRestDay {
                    restDayToggle(isOn: rest)
                }
            }

            // Dia de descanso: substitui o slider por um texto centralizado.
            if isRestDay?.wrappedValue == true {
                Text(String(localized: "today.restday.label", bundle: .gymNutshellCore))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 6)
            } else if safeGoal > 0 {
                Slider(
                    value: sliderBinding,
                    in: 0...Double(safeGoal)
                )
                .tint(progressTint)
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }

    // Botão OFF/ON para alternar modo "dia de descanso".
    // OFF (cinza) → tap aciona descanso. ON (accent) → tap volta slider com valor zerado.
    private func restDayToggle(isOn: Binding<Bool>) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(.easeInOut(duration: 0.15)) {
                if isOn.wrappedValue {
                    isOn.wrappedValue = false
                    value = 0
                } else {
                    isOn.wrappedValue = true
                }
            }
        } label: {
            Text(isOn.wrappedValue
                 ? String(localized: "today.restday.on", bundle: .gymNutshellCore)
                 : String(localized: "today.restday.off", bundle: .gymNutshellCore))
                .font(.caption.weight(.bold))
                .foregroundStyle(isOn.wrappedValue ? Color.secondary : accentColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule().fill(isOn.wrappedValue ? accentColor.opacity(0.25) : Color.secondary.opacity(0.20))
                )
        }
        .buttonStyle(.plain)
        // No macOS (iPad App on Mac) o Button respeita uma altura mínima do
        // sistema e estica o conteúdo, deixando o capsule "gordo e estreito".
        // .fixedSize força o botão a usar o tamanho intrínseco do label igual no iOS.
        .fixedSize()
    }
}
