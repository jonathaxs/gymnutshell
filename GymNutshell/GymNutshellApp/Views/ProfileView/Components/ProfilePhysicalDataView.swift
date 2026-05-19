// ⌘
//  GymNutshell/GymNutshellApp/Views/ProfileView/Components/ProfilePhysicalDataView.swift
//
//  Propósito: Card que exibe altura, peso, idade e sexo nas unidades preferidas do usuário.
//             Só aparece quando pelo menos um campo foi preenchido.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-28.
// ⌘

import SwiftUI
import GymNutshellCore

/// Card de dados físicos com linhas pra altura, peso, idade e sexo.
/// Os valores são convertidos do armazenamento em métrico pro sistema de medidas preferido do usuário.
struct ProfilePhysicalDataView: View {

    let height: Int
    let weight: Double
    let age: Int
    let sex: String
    let measurementSystem: MeasurementSystem
    var accentColor: Color = Color(.separator)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(String(localized: "profile.physical.section", bundle: .gymNutshellCore))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

            Rectangle()
                .fill(accentColor.opacity(0.25))
                .frame(height: 1)

            if height > 0 {
                physicalRow(
                    label: String(localized: "profile.physical.height", bundle: .gymNutshellCore),
                    value: heightDisplay
                )
                Rectangle().fill(accentColor.opacity(0.25)).frame(height: 1).padding(.leading, 16)
            }
            if weight > 0 {
                physicalRow(
                    label: String(localized: "profile.physical.weight", bundle: .gymNutshellCore),
                    value: weightDisplay
                )
                Rectangle().fill(accentColor.opacity(0.25)).frame(height: 1).padding(.leading, 16)
            }
            if age > 0 {
                physicalRow(label: String(localized: "profile.physical.age", bundle: .gymNutshellCore), value: "\(age)")
                Rectangle().fill(accentColor.opacity(0.25)).frame(height: 1).padding(.leading, 16)
            }
            if !sex.isEmpty {
                physicalRow(label: String(localized: "profile.physical.sex", bundle: .gymNutshellCore), value: sexLabel)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - Valores formatados

    private var heightDisplay: String {
        switch measurementSystem {
        case .metric:
            return "\(height) cm"
        case .us, .uk:
            let (feet, inches) = UnitConverter.cmToFeetAndInches(height)
            return "\(feet)'\(inches)\""
        }
    }

    private var weightDisplay: String {
        switch measurementSystem {
        case .metric:
            return String(format: "%.1f kg", weight)
        case .us:
            return String(format: "%.1f lbs", UnitConverter.kgToLbs(weight))
        case .uk:
            let (stones, lbs) = UnitConverter.kgToStoneLbs(weight)
            return "\(stones) st \(lbs) lbs"
        }
    }

    private var sexLabel: String {
        switch sex {
        case "male":   return String(localized: "profile.sex.male", bundle: .gymNutshellCore)
        case "female": return String(localized: "profile.sex.female", bundle: .gymNutshellCore)
        default:       return String(localized: "profile.sex.other", bundle: .gymNutshellCore)
        }
    }

    private func physicalRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}
