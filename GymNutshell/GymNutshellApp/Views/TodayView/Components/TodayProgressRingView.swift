// ⌘
//  GymNutshell/GymNutshellApp/Views/TodayView/Components/TodayProgressRingView.swift
//
//  Propósito: Anel de progresso circular pro bloco hero da TodayView.
//             A cor varia vermelho→laranja→verde→azul conforme o progresso aumenta.
//             Expande com um tom roxo quando o usuário pressiona.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-19.
// ⌘

import SwiftUI
import GymNutshellCore

// MARK: - TodayProgressRingView

// Mostra o progresso geral do dia (metas de rastreio + check-in) como um anel.
// Pressionar causa um efeito de expansão spring com tint roxo — puramente visual, sem navegação.
struct TodayProgressRingView: View {

    let progress: Double
    /// Chamado quando o usuário toca (não pressiona) o anel — abre a sheet de informação.
    var onTap: (() -> Void)? = nil

    var size: CGFloat = 108
    var lineWidth: CGFloat = 12

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @GestureState private var isPressed: Bool = false

    // MARK: - Valores derivados

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var percentage: Int {
        // Truncação pra paridade com dailyPercentage (TodayView), widget do iPhone
        // e Watch — todos usam .rounded(.down). Truncar é o correto pra anel:
        // "9%" significa "pelo menos 9% feito". Padrão Apple Activity rings.
        Int((clampedProgress * 100).rounded(.down))
    }

    // Cor reflete o nível de progresso; vira roxo ao pressionar.
    private var ringColor: Color {
        if isPressed { return .purple }
        switch clampedProgress {
        case ..<0.30: return .red
        case ..<0.60: return .orange
        case ..<1.0:  return .green
        default:      return .blue
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Trilha de fundo
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)

            // Arco de progresso — começa no topo (rotacionado -90°), ponta arredondada
            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: clampedProgress)

            // Label de porcentagem
            Text("\(percentage)%")
                .font(.title3.weight(.semibold).monospacedDigit())
                .foregroundStyle(ringColor)
                .contentTransition(.numericText())
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: percentage)
                .accessibilityHidden(true)
        }
        .frame(width: size, height: size)
        // Expande ao pressionar
        .scaleEffect(isPressed ? 1.20 : 1.0)
        .animation(
            reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.50),
            value: isPressed
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    state = true
                }
        )
        // Tap abre a sheet de informação do anel (se o callback foi fornecido).
        .simultaneousGesture(
            TapGesture().onEnded { onTap?() }
        )
        // Acessibilidade
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "today.ring.a11y.label", bundle: .gymNutshellCore))
        .accessibilityHint(String(localized: "today.ring.a11y.hint", bundle: .gymNutshellCore))
        .accessibilityValue(String(format: String(localized: "today.ring.a11y.value", bundle: .gymNutshellCore), percentage))
    }
}
