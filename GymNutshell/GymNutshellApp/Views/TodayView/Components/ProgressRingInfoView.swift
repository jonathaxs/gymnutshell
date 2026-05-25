// ⌘
//  GymNutshell/GymNutshellApp/Views/TodayView/Components/ProgressRingInfoView.swift
//
//  Propósito: View informativa sobre o anel de progresso.
//             Exibida como sheet quando o usuário toca no TodayProgressRingView e
//             também acessível em Configurações > Sobre > Anel de Progresso.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-15.
// ⌘

import SwiftUI
import GymNutshellCore

/// Exibe uma explicação sobre o anel de progresso diário:
/// o que ele representa, como a porcentagem é calculada e o que cada cor significa.
struct ProgressRingInfoView: View {

    var isSheet: Bool = false
    /// Percentual atual do dia (0–100), passado pela TodayHeroView quando aberto como sheet.
    /// nil quando acessado via Settings > Sobre (sem contexto de progresso atual).
    var currentPercent: Int? = nil

    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color { (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color }

    // Próximo nível de cor do anel a alcançar, com nome, cor e distância em pontos percentuais.
    // nil quando o anel já está em 100% (nível máximo).
    private var ringNextLevel: (percent: Int, name: String, color: Color, level: Int)? {
        guard let p = currentPercent, p < 100 else { return nil }
        if p < 33 { return (33 - p,  String(localized: "ring.info.color.orange", bundle: .gymNutshellCore), .orange, 2) }
        if p < 66 { return (66 - p,  String(localized: "ring.info.color.green", bundle: .gymNutshellCore),  .green,  3) }
        if p < 90 { return (90 - p,  String(localized: "ring.info.color.cyan", bundle: .gymNutshellCore),   .cyan,   4) }
        return            (100 - p, String(localized: "ring.info.color.blue", bundle: .gymNutshellCore),   .blue,   5)
    }

    // Cores do anel em ordem crescente de progresso.
    private var ringColors: [(label: String, color: Color, range: String)] {
        let suffix = String(localized: "tier.info.range.suffix", bundle: .gymNutshellCore)
        return [
            (String(localized: "ring.info.color.red", bundle: .gymNutshellCore),    .red,    "0 – 32%" + suffix),
            (String(localized: "ring.info.color.orange", bundle: .gymNutshellCore), .orange, "33 – 65%" + suffix),
            (String(localized: "ring.info.color.green", bundle: .gymNutshellCore),  .green,  "66 – 89%" + suffix),
            (String(localized: "ring.info.color.cyan", bundle: .gymNutshellCore),   .cyan,   "90 – 99%" + suffix),
            (String(localized: "ring.info.color.blue", bundle: .gymNutshellCore),   .blue,   "100%" + suffix)
        ]
    }

    var body: some View {
        List {
            // Intro + frase de progresso na mesma seção pra reduzir o espaço entre eles.
            Section {
                Text(String(localized: "ring.info.intro", bundle: .gymNutshellCore))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)

                if let p = currentPercent, p >= 100 {
                    Text(String(localized: "today.max.level", bundle: .gymNutshellCore))
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                } else if let next = ringNextLevel {
                    (Text(String(localized: "info.next.prefix", bundle: .gymNutshellCore))
                     + Text("\(next.percent)")
                     + Text("%")
                     + Text(String(localized: "info.next.middle", bundle: .gymNutshellCore))
                     + Text("\n")
                     + Text(next.name).foregroundStyle(.primary))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                }
            }
            .listRowBackground(Color.clear)

            // Seção das cores, sem indicador de nível.
            Section(String(localized: "ring.info.section.colors", bundle: .gymNutshellCore)) {
                ForEach(ringColors, id: \.label) { item in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 24, height: 24)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.label)
                                .font(.subheadline.weight(.semibold))
                            Text(item.range)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(String(format: String(localized: "a11y.ringinfo.color.row.format",
                                                             bundle: .gymNutshellCore),
                                               item.label, item.range))
                }
            }
        }
        .navigationTitle(String(localized: "settings.about.progressRing", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isSheet {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(String(localized: "common.close", bundle: .gymNutshellCore))
                            .foregroundStyle(accentColor)
                    }
                }
            }
        }
    }
}
