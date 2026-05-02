// ⌘
//  GymNutshellCore/Stores/MeasurementSystem.swift
//
//  Propósito: Define os três sistemas de medida suportados e fornece o padrão
//             com base no locale do aparelho.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-22.
// ⌘

import Foundation

/// Os três sistemas de medida suportados pelo app.
public enum MeasurementSystem: String, CaseIterable, Sendable {
    case metric
    case us     // libras, pés/polegadas, fluid ounces
    case uk     // stones+lbs, pés/polegadas, mililitros
}

/// Gerencia a preferência de sistema de medida do usuário.
public enum MeasurementSystemStore {

    public static let key = UserProfile.measurementSystemKey

    public static func detectDefault() -> MeasurementSystem {
        switch Locale.current.measurementSystem {
        case .us: return .us
        case .uk: return .uk
        default:  return .metric
        }
    }
}
