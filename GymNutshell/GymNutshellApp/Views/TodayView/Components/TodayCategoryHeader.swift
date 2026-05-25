// ⌘
//  GymNutshell/GymNutshellApp/Views/TodayView/Components/TodayCategoryHeader.swift
//
//  Propósito: Header colapsável de categoria em Hoje, texto centralizado,
//             chevron e fundo arredondado que sinaliza estado aberto/recolhido.
//             Compartilhado entre categorias fixas e categorias criadas pelo usuário.
// ⌘

import SwiftUI
import GymNutshellCore

struct TodayCategoryHeader: View {
    let title: String
    let collapsed: Bool
    let accentColor: Color
    let a11yLabel: String
    let a11yHint: String
    let onToggle: () -> Void

    var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(.easeInOut(duration: 0.2)) {
                onToggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: collapsed ? "chevron.right" : "chevron.down")
                    .font(.caption2.weight(.bold))
                    .frame(width: 12)
                Text(title.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundStyle(Color.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background {
                if collapsed {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 14,
                        bottomTrailingRadius: 14,
                        topTrailingRadius: 0
                    )
                    .fill(Color.secondary.opacity(0.20))
                } else {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 14,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 14
                    )
                    .fill(accentColor.opacity(0.22))
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
        .padding(.bottom, 2)
        .accessibilityLabel(a11yLabel)
        .accessibilityHint(a11yHint)
    }
}
