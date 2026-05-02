// ⌘
//  GymNutshell/GymNutshellApp/Views/Shared/UserGoalPickerView.swift
//
//  Propósito: Picker reutilizável baseado em cards pra selecionar um UserGoal.
//             Usado no WelcomeUserGoalStep (onboarding) e no UserGoalChangeView (settings).
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-11.
// ⌘

import SwiftUI
import GymNutshellCore

/// Exibe um card selecionável por opção de UserGoal.
/// O card selecionado é destacado e o binding é atualizado ao tocar.
struct UserGoalPickerView: View {

    @Binding var selection: UserGoal

    var body: some View {
        VStack(spacing: 12) {
            ForEach(UserGoal.allCases) { goal in
                goalCard(goal)
            }
        }
    }

    // MARK: - Card de objetivo

    private func goalCard(_ goal: UserGoal) -> some View {
        let isSelected = selection == goal

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selection = goal
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.label)
                        .font(.headline)
                        .foregroundStyle(isSelected ? .white : .primary)

                    Text(goalDescription(goal))
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .background(isSelected ? goalColor(goal) : Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func goalColor(_ goal: UserGoal) -> Color {
        switch goal {
        case .bulking:     return .orange
        case .maintenance: return .accentColor
        case .cutting:     return .green
        }
    }

    private func goalDescription(_ goal: UserGoal) -> String {
        switch goal {
        case .bulking:      return String(localized: "welcome.goal.bulking.description", bundle: .gymNutshellCore)
        case .maintenance:  return String(localized: "welcome.goal.maintenance.description", bundle: .gymNutshellCore)
        case .cutting:      return String(localized: "welcome.goal.cutting.description", bundle: .gymNutshellCore)
        }
    }
}
