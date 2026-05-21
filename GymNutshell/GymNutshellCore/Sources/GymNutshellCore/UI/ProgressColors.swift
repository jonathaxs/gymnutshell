// ⌘
//  GymNutshellCore/Sources/GymNutshellCore/UI/ProgressColors.swift
//
//  Propósito: Regra única de mapeamento progresso → cor do anel/barra,
//             usada em todas as superfícies (iPhone, Watch, widgets).
//             Faixas: <30% vermelho, <60% laranja, <100% verde, =100% azul.
// ⌘

import SwiftUI

public enum ProgressColors {
    /// Cor do anel/barra de progresso seguindo a regra <30%/<60%/<100%/100%.
    /// Mesma escala usada em TodayProgressRingView, TrackingGoalRowView, widgets e Watch.
    public static func ring(for progress: Double) -> Color {
        switch progress {
        case ..<0.30: return .red
        case ..<0.60: return .orange
        case ..<1.0:  return .green
        default:      return .blue
        }
    }
}
