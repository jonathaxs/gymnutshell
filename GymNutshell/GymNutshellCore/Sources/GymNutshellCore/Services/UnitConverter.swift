// ⌘
//  GymNutshellCore/Services/UnitConverter.swift
//
//  Propósito: Converte valores de peso e altura entre unidades métricas e imperiais.
//             O app sempre guarda valores em kg e cm internamente.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-22.
// ⌘

import Foundation

/// Converte peso e altura entre unidades métricas e imperiais.
public enum UnitConverter {

    // MARK: - Peso (US: libras)

    public static func kgToLbs(_ kg: Double) -> Double {
        kg * 2.20462
    }

    public static func lbsToKg(_ lbs: Double) -> Double {
        lbs / 2.20462
    }

    // MARK: - Peso (UK: stones + libras)

    public static func kgToStoneLbs(_ kg: Double) -> (stones: Int, lbs: Int) {
        let totalLbs = kg * 2.20462
        let stones = Int(totalLbs / 14)
        let remainingLbs = Int(totalLbs.rounded()) - stones * 14
        return (stones, remainingLbs)
    }

    public static func stoneLbsToKg(stones: Int, lbs: Int) -> Double {
        Double(stones * 14 + lbs) / 2.20462
    }

    // MARK: - Água

    public static func mlToFlOz(_ ml: Double) -> Double {
        ml / 29.5735
    }

    public static func flOzToMl(_ flOz: Double) -> Double {
        flOz * 29.5735
    }

    // MARK: - Altura

    public static func cmToFeetAndInches(_ cm: Int) -> (feet: Int, inches: Int) {
        let totalInches = Int((Double(cm) / 2.54).rounded())
        return (totalInches / 12, totalInches % 12)
    }

    public static func feetAndInchesToCm(feet: Int, inches: Int) -> Int {
        Int((Double(feet * 12 + inches) * 2.54).rounded())
    }
}
