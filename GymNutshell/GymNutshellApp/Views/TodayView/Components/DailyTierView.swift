// ⌘
//  GymNutshell/GymNutshellApp/Views/TodayView/Components/DailyTierView.swift
//
//  Propósito: Mostra o nível atual de DailyAchievement no bloco hero da TodayView.
//             Exibe emoji, nome do nível e o nível com a faixa percentual.
//             Expande quando pressionado — sem navegação.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-19.
// ⌘

import SwiftUI
import GymNutshellCore

// MARK: - DailyTierView

// Elemento hero que mostra o nível de conquista atual do usuário hoje.
// Escala e opacidade do emoji refletem o nível.
// Press causa um efeito de expansão spring — puramente decorativo, igual ao anel de progresso.
struct DailyTierView: View {

    let achievement: DailyAchievement
    let theme: AppTheme
    /// Chamado quando o usuário toca (não pressiona longamente) o tier.
    var onTap: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Sexo do usuário — usado pra selecionar o nome de tier no gênero correto.
    @AppStorage(UserProfile.sexKey) private var sex: String = "male"

    @GestureState private var isPressed: Bool = false

    // MARK: - Apresentação do emoji por nível

    // Emoji cresce levemente em níveis mais altos pra reforçar visualmente o progresso.
    private var emojiScale: CGFloat {
        switch achievement {
        case .level1: return 0.95
        case .level2: return 1.0
        case .level3: return 1.05
        case .level4: return 1.10
        }
    }

    // Nível 1 fica levemente escurecido pra refletir que o dia tá só começando.
    private var emojiOpacity: Double {
        achievement == .level1 ? 0.85 : 1.0
    }

    // MARK: - Body

    var body: some View {
        // Tudo (header "Conquista" + emoji + nome) num só VStack que escala junto
        // no press e vira UM elemento de VoiceOver — "Conquista de hoje, Galo, botão".
        // O texto "Conquista" fica visível mas não fala separado: o label custom
        // já encapsula "Conquista de hoje" na frase.
        VStack(spacing: 6) {
            Text(String(localized: "today.tier.label.achievement", bundle: .gymNutshellCore))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(theme.emoji(for: achievement, sex: sex))
                .font(.system(size: 72))
                .scaleEffect(emojiScale)
                .opacity(emojiOpacity)
                .animation(
                    reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.75),
                    value: theme.emoji(for: achievement, sex: sex)
                )

            Text(theme.name(for: achievement, sex: sex))
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
        }
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
        .simultaneousGesture(
            TapGesture().onEnded { onTap?() }
        )
        // Acessibilidade — label combina "Conquista de hoje" + nome do tier;
        // hint genérico abre a sheet. Sem value (pontos confundem com tiers de
        // emoji como Galo).
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(String(format: String(localized: "today.tier.a11y.label",
                                                 bundle: .gymNutshellCore),
                                   theme.emoji(for: achievement, sex: sex),
                                   theme.name(for: achievement, sex: sex)))
        .accessibilityHint(A11y.moreInfoHint())
    }
}
