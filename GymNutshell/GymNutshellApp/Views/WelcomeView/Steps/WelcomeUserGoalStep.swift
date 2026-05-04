// ⌘
//  GymNutshell/GymNutshellApp/Views/WelcomeView/Steps/WelcomeUserGoalStep.swift
//
//  Propósito: Etapa do onboarding — permite ao usuário escolher seu objetivo de fitness
//             (bulking, manutenção ou cutting) via cards selecionáveis.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-10.
// ⌘

import SwiftUI
import GymNutshellCore

/// Etapa do onboarding: exibe um card pra cada opção de UserGoal.
/// O card selecionado fica destacado e é devolvido via binding pra WelcomeView.
/// A UI dos cards é gerenciada pela UserGoalPickerView compartilhada.
struct WelcomeUserGoalStep: View {

    @Binding var userGoal: UserGoal
    var isWide: Bool = false

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    if !isWide {
                        WelcomeStepHeader(
                            emoji: "🎯",
                            title: String(localized: "welcome.step.goal.title", bundle: .gymNutshellCore)
                        )
                    }

                    UserGoalPickerView(selection: $userGoal)

                    VStack(alignment: .center, spacing: 4) {
                        Text(String(localized: "welcome.step.goal.info.choose", bundle: .gymNutshellCore))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(String(localized: "welcome.step.goal.info.editable", bundle: .gymNutshellCore))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: isWide ? geo.size.height : 0, alignment: .center)
            }
        }
    }
}
