// ⌘
//  GymNutshell/GymNutshellApp/Views/ProfileView/Components/ProgressOverviewCard.swift
//
//  Propósito: Card de seção usado na ProgressOverView — título, divisória colorida
//             com a cor de destaque do usuário e bloco de linhas.
// ⌘

import SwiftUI

/// Card de estatísticas com cabeçalho e divisória colorida. Usado em
/// `ProgressOverView` pra agrupar listas de `TierRow`/`BonusRow`/`ActivityRow`/`GoalsRow`.
struct StatisticsCard<Rows: View>: View {
    let title: String
    let accentColor: Color
    /// Quando `true`, título e divisória ficam centralizados horizontalmente.
    var centered: Bool = false
    @ViewBuilder var rows: () -> Rows

    var body: some View {
        VStack(alignment: centered ? .center : .leading, spacing: 0) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: centered ? .infinity : nil,
                       alignment: centered ? .center : .leading)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)
            Rectangle()
                .fill(accentColor.opacity(0.25))
                .frame(height: 1)
            rows()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

/// Divisória fina com a cor de destaque, usada entre linhas dentro de um `StatisticsCard`.
struct AccentDivider: View {
    let accentColor: Color

    var body: some View {
        Rectangle()
            .fill(accentColor.opacity(0.25))
            .frame(height: 1)
            .padding(.leading, 16)
    }
}
