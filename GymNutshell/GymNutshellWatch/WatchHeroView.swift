// ⌘
//  GymNutshellWatch/WatchHeroView.swift
//
//  Propósito: Hero superior do Watch app — anel de progresso médio do dia
//             + emoji do tier + nome do tier + percentual.
//             Cor do anel acompanha o tier (vermelho/laranja/verde/azul).
// ⌘

import SwiftUI
import GymNutshellCore

struct WatchHeroView: View {
    let averageProgress: Double
    let theme: AppTheme
    let tier: DailyAchievement
    let sex: String

    // Cor do anel acompanha o tier do dia, igual TodayProgressRingView do iPhone:
    // <30% vermelho (just starting), <60% laranja (on your way),
    // <100% verde (almost there), 100% azul (goal complete).
    private var ringColor: Color {
        ProgressColors.ring(for: averageProgress)
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: averageProgress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: averageProgress)

                Text(theme.emoji(for: tier, sex: sex))
                    .font(.system(size: 36))
            }
            .frame(width: 100, height: 100)

            Text(theme.name(for: tier, sex: sex))
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            Text("\(Int(averageProgress * 100))%")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(ringColor)
        }
        // Combina anel + tier + percentual em uma única locução, mesma estrutura
        // do iPhone TodayProgressRingView: "Daily progress, Big Cat, 65 percent completed".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            String(localized: "a11y.watch.hero.label", bundle: .gymNutshellCore)
            + ", " + theme.name(for: tier, sex: sex)
        )
        .accessibilityValue(A11y.progressValue(percent: Int(averageProgress * 100)))
    }
}
