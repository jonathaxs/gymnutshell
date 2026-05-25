// ⌘
//  GymNutshellCore/Sources/GymNutshellCore/UI/ProgressColors.swift
//
//  Propósito: Regra única de mapeamento progresso → cor do anel/barra,
//             usada em todas as superfícies (iPhone, Watch, widgets).
//             Faixas: <33% vermelho, <66% laranja, <90% verde, <100% ciano, =100% azul.
// ⌘

import SwiftUI

public enum ProgressColors {
    /// Cor do anel/barra de progresso seguindo a regra <33%/<66%/<90%/<100%/100%.
    /// Mesma escala usada em TodayProgressRingView, TrackingGoalRowView, widgets e Watch.
    public static func ring(for progress: Double) -> Color {
        switch progress {
        case ..<0.33: return .red
        case ..<0.66: return .orange
        case ..<0.90: return .green
        case ..<1.0:  return .cyan
        default:      return .blue
        }
    }
}
