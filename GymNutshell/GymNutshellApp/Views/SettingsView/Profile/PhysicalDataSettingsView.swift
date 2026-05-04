// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Profile/PhysicalDataSettingsView.swift
//
//  Propósito: Permite ao usuário revisar e atualizar o nome e os dados físicos
//             (peso, altura, idade, sexo) guardados durante o onboarding.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-11.
// ⌘

import SwiftUI
import GymNutshellCore

/// Tela de settings pra editar o nome e os dados físicos do usuário.
/// Lê os valores atuais do UserDefaults ao aparecer e salva de volta ao confirmar.
struct PhysicalDataSettingsView: View {

    @Environment(\.dismiss) private var dismiss

    // MARK: - Sistema de medidas

    @AppStorage(UserProfile.measurementSystemKey) private var measurementSystem: MeasurementSystem = .metric

    // MARK: - Campos de rascunho

    @State private var name: String = ""
    @State private var weightText: String = ""
    @State private var weightStonesText: String = ""
    @State private var weightStoneLbsText: String = ""
    @State private var heightText: String = ""
    @State private var heightFeetText: String = ""
    @State private var heightInchesText: String = ""
    @State private var birthday: Date = Self.defaultBirthday
    @State private var sex: String = "other"
    // Easter egg — exercício/grupo muscular favorito.
    @AppStorage(UserProfile.favoriteExerciseKey) private var favoriteExerciseRaw: String = FavoriteExercise.unknown.rawValue

    // Data de nascimento padrão exibida quando o usuário ainda não escolheu uma —
    // usa 25 anos atrás (idade default antiga do app), evitando "0 anos".
    private static var defaultBirthday: Date {
        Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    }

    // Range válido pro DatePicker — de 120 anos atrás até a data de hoje.
    private var birthdayRange: ClosedRange<Date> {
        let now = Date()
        let minDate = Calendar.current.date(byAdding: .year, value: -120, to: now) ?? now
        return minDate...now
    }

    // MARK: - Foco do teclado

    private enum Field: Hashable {
        case name
        case weightMetric, weightUS, weightStones, weightStoneLbs
        case heightMetric, heightFeet, heightInches
    }

    @FocusState private var focusedField: Field?

    // Ordem dos campos conforme o sistema de medidas atual.
    private var orderedFields: [Field] {
        var fields: [Field] = [.name]
        switch measurementSystem {
        case .metric:
            fields += [.weightMetric, .heightMetric]
        case .us:
            fields += [.weightUS, .heightFeet, .heightInches]
        case .uk:
            fields += [.weightStones, .weightStoneLbs, .heightFeet, .heightInches]
        }
        return fields
    }

    private var isLastField: Bool {
        guard let current = focusedField,
              let idx = orderedFields.firstIndex(of: current) else { return false }
        return idx == orderedFields.count - 1
    }

    private func advanceFocus() {
        guard let current = focusedField,
              let idx = orderedFields.firstIndex(of: current),
              idx + 1 < orderedFields.count else {
            focusedField = nil
            return
        }
        focusedField = orderedFields[idx + 1]
    }

    // MARK: - Body

    var body: some View {
        Form {
            Section(String(localized: "settings.profile.section.personal", bundle: .gymNutshellCore)) {
                LabeledContent(String(localized: "settings.profile.name", bundle: .gymNutshellCore)) {
                    TextField(String(localized: "settings.profile.name.placeholder", bundle: .gymNutshellCore), text: $name)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .name)
                        .submitLabel(isLastField ? .done : .next)
                        .onSubmit { advanceFocus() }
                }
                Picker(String(localized: "settings.profile.favoriteExercise", bundle: .gymNutshellCore),
                       selection: $favoriteExerciseRaw) {
                    ForEach(FavoriteExercise.allCases) { exercise in
                        Text(exercise.label).tag(exercise.rawValue)
                    }
                }
            }

            Section(String(localized: "settings.profile.section.physical", bundle: .gymNutshellCore)) {
                switch measurementSystem {
                case .metric:
                    LabeledContent(String(localized: "settings.profile.weight", bundle: .gymNutshellCore)) {
                        TextField("kg", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .weightMetric)
                            .onChange(of: weightText) { _, new in
                                let clamped = Self.clampDigits(new, maxDigits: 3, allowDecimal: true)
                                if clamped != new { weightText = clamped }
                            }
                    }
                case .us:
                    LabeledContent(String(localized: "settings.profile.weight.lbs", bundle: .gymNutshellCore)) {
                        TextField("lbs", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .weightUS)
                            .onChange(of: weightText) { _, new in
                                let clamped = Self.clampDigits(new, maxDigits: 3, allowDecimal: true)
                                if clamped != new { weightText = clamped }
                            }
                    }
                case .uk:
                    LabeledContent(String(localized: "settings.profile.weight.uk", bundle: .gymNutshellCore)) {
                        HStack(spacing: 4) {
                            TextField("11", text: $weightStonesText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 44)
                                .focused($focusedField, equals: .weightStones)
                                .onChange(of: weightStonesText) { _, new in
                                    let clamped = Self.clampDigits(new, maxDigits: 2)
                                    if clamped != new { weightStonesText = clamped }
                                }
                            Text(String(localized: "settings.profile.weight.stones.unit", bundle: .gymNutshellCore))
                                .foregroundStyle(.secondary)
                            TextField("5", text: $weightStoneLbsText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 44)
                                .focused($focusedField, equals: .weightStoneLbs)
                                .onChange(of: weightStoneLbsText) { _, new in
                                    let clamped = Self.clampDigits(new, maxDigits: 2)
                                    if clamped != new { weightStoneLbsText = clamped }
                                }
                            Text(String(localized: "settings.profile.weight.stonelbs.unit", bundle: .gymNutshellCore))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if measurementSystem == .metric {
                    LabeledContent(String(localized: "settings.profile.height", bundle: .gymNutshellCore)) {
                        TextField("cm", text: $heightText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .heightMetric)
                            .onChange(of: heightText) { _, new in
                                let clamped = Self.clampDigits(new, maxDigits: 3)
                                if clamped != new { heightText = clamped }
                            }
                    }
                } else {
                    LabeledContent(String(localized: "settings.profile.height.imperial", bundle: .gymNutshellCore)) {
                        HStack(spacing: 4) {
                            TextField("5", text: $heightFeetText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 44)
                                .focused($focusedField, equals: .heightFeet)
                                .onChange(of: heightFeetText) { _, new in
                                    let clamped = Self.clampDigits(new, maxDigits: 1)
                                    if clamped != new { heightFeetText = clamped }
                                }
                            Text(String(localized: "settings.profile.height.feet.unit", bundle: .gymNutshellCore))
                                .foregroundStyle(.secondary)
                            TextField("8", text: $heightInchesText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 44)
                                .focused($focusedField, equals: .heightInches)
                                .onChange(of: heightInchesText) { _, new in
                                    let clamped = Self.clampDigits(new, maxDigits: 2)
                                    if clamped != new { heightInchesText = clamped }
                                }
                            Text(String(localized: "settings.profile.height.inches.unit", bundle: .gymNutshellCore))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Picker(String(localized: "settings.profile.sex", bundle: .gymNutshellCore), selection: $sex) {
                    Text(String(localized: "profile.sex.male", bundle: .gymNutshellCore)).tag("male")
                    Text(String(localized: "profile.sex.female", bundle: .gymNutshellCore)).tag("female")
                    Text(String(localized: "profile.sex.other", bundle: .gymNutshellCore)).tag("other")
                }
                DatePicker(
                    String(localized: "settings.profile.birthday", bundle: .gymNutshellCore),
                    selection: $birthday,
                    in: birthdayRange,
                    displayedComponents: .date
                )
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(String(localized: "settings.section.physicaldata", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                if isLastField {
                    Button(String(localized: "keyboard.done", bundle: .gymNutshellCore)) {
                        focusedField = nil
                    }
                } else {
                    Button(String(localized: "keyboard.next", bundle: .gymNutshellCore)) {
                        advanceFocus()
                    }
                }
            }
        }
        .onAppear {
            load()
        }
        .onChange(of: fieldsSnapshot) { _, _ in autoSave() }
    }

    private var fieldsSnapshot: String {
        [name, weightText, weightStonesText, weightStoneLbsText,
         heightText, heightFeetText, heightInchesText,
         "\(birthday.timeIntervalSince1970)", sex]
            .joined(separator: "|")
    }

    private func autoSave() {
        save()
    }

    // Trunca `text` pra conter no máximo `maxDigits` algarismos.
    // Se `allowDecimal` é true, aceita um único ponto/vírgula, mantendo até 1 casa decimal.
    private static func clampDigits(_ text: String, maxDigits: Int, allowDecimal: Bool = false) -> String {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        if allowDecimal {
            let parts = normalized.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
            let intPart = String(parts.first ?? "").filter(\.isNumber).prefix(maxDigits)
            if parts.count > 1 {
                let frac = String(parts[1]).filter(\.isNumber).prefix(1)
                return "\(intPart)." + frac
            }
            // Preserva o ponto se o usuário acabou de digitar "70."
            if normalized.contains(".") { return "\(intPart)." }
            return String(intPart)
        } else {
            let digits = normalized.filter(\.isNumber).prefix(maxDigits)
            return String(digits)
        }
    }

    // MARK: - Validação

    private var isValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        guard UserProfile.age(from: birthday) > 0 else { return false }

        switch measurementSystem {
        case .metric:
            guard let weight = Double(weightText), weight > 0 else { return false }
            guard let height = Int(heightText), height > 0 else { return false }
        case .us:
            guard let weight = Double(weightText), weight > 0 else { return false }
            guard let feet = Int(heightFeetText), feet > 0 else { return false }
            let inches = Int(heightInchesText) ?? 0
            guard inches >= 0, inches < 12 else { return false }
        case .uk:
            guard let stones = Int(weightStonesText), stones >= 1 else { return false }
            let stoneLbs = Int(weightStoneLbsText) ?? 0
            guard stoneLbs >= 0, stoneLbs < 14 else { return false }
            guard let feet = Int(heightFeetText), feet > 0 else { return false }
            let inches = Int(heightInchesText) ?? 0
            guard inches >= 0, inches < 12 else { return false }
        }
        return true
    }

    // MARK: - Carregar / Salvar

    private func load() {
        let defaults = UserDefaults.standard
        name = defaults.string(forKey: UserProfile.nameKey) ?? ""

        let weightKg = defaults.double(forKey: UserProfile.weightKey)
        let heightCm = defaults.integer(forKey: UserProfile.heightKey)

        switch measurementSystem {
        case .metric:
            weightText = weightKg > 0 ? String(format: "%.1f", weightKg) : ""
            heightText = heightCm > 0 ? "\(heightCm)" : ""
        case .us:
            weightText = weightKg > 0 ? String(format: "%.1f", UnitConverter.kgToLbs(weightKg)) : ""
            if heightCm > 0 {
                let (feet, inches) = UnitConverter.cmToFeetAndInches(heightCm)
                heightFeetText = "\(feet)"
                heightInchesText = "\(inches)"
            }
        case .uk:
            if weightKg > 0 {
                let (stones, lbs) = UnitConverter.kgToStoneLbs(weightKg)
                weightStonesText = "\(stones)"
                weightStoneLbsText = "\(lbs)"
            }
            if heightCm > 0 {
                let (feet, inches) = UnitConverter.cmToFeetAndInches(heightCm)
                heightFeetText = "\(feet)"
                heightInchesText = "\(inches)"
            }
        }

        if let stored = UserProfile.storedBirthday() {
            birthday = stored
        } else {
            // Migração: se só temos a idade antiga, reconstrói uma data de nascimento aproximada
            // (1 de janeiro de `ano atual - idade`) pra manter continuidade. Usuário pode ajustar.
            let storedAge = defaults.integer(forKey: UserProfile.ageKey)
            if storedAge > 0 {
                var comps = DateComponents()
                comps.year = Calendar.current.component(.year, from: Date()) - storedAge
                comps.month = 1
                comps.day = 1
                birthday = Calendar.current.date(from: comps) ?? Self.defaultBirthday
            } else {
                birthday = Self.defaultBirthday
            }
        }
        sex = defaults.string(forKey: UserProfile.sexKey) ?? "other"
    }

    private func save() {
        let defaults = UserDefaults.standard
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        defaults.set(trimmedName, forKey: UserProfile.nameKey)
        defaults.set(sex, forKey: UserProfile.sexKey)

        defaults.set(birthday.timeIntervalSince1970, forKey: UserProfile.birthdayKey)
        defaults.set(UserProfile.age(from: birthday), forKey: UserProfile.ageKey)

        var savedWeightKg: Double?
        switch measurementSystem {
        case .metric:
            if let weight = Double(weightText), weight > 0 {
                savedWeightKg = weight
                defaults.set(weight, forKey: UserProfile.weightKey)
            }
            if let height = Int(heightText), height > 0 {
                defaults.set(height, forKey: UserProfile.heightKey)
            }
        case .us:
            if let weightLbs = Double(weightText), weightLbs > 0 {
                let kg = UnitConverter.lbsToKg(weightLbs)
                savedWeightKg = kg
                defaults.set(kg, forKey: UserProfile.weightKey)
            }
            if let feet = Int(heightFeetText), feet > 0 {
                let inches = Int(heightInchesText) ?? 0
                if inches >= 0, inches < 12 {
                    defaults.set(UnitConverter.feetAndInchesToCm(feet: feet, inches: inches),
                                 forKey: UserProfile.heightKey)
                }
            }
        case .uk:
            if let stones = Int(weightStonesText), stones >= 1 {
                let lbs = Int(weightStoneLbsText) ?? 0
                if lbs >= 0, lbs < 14 {
                    let kg = UnitConverter.stoneLbsToKg(stones: stones, lbs: lbs)
                    savedWeightKg = kg
                    defaults.set(kg, forKey: UserProfile.weightKey)
                }
            }
            if let feet = Int(heightFeetText), feet > 0 {
                let inches = Int(heightInchesText) ?? 0
                if inches >= 0, inches < 12 {
                    defaults.set(UnitConverter.feetAndInchesToCm(feet: feet, inches: inches),
                                 forKey: UserProfile.heightKey)
                }
            }
        }

        if let weightKg = savedWeightKg {
            let goalRaw = defaults.string(forKey: UserProfile.userGoalKey) ?? UserGoal.maintenance.rawValue
            let userGoal = UserGoal(rawValue: goalRaw) ?? .maintenance
            let newGoals = GoalsCalculator.calculate(weightKg: weightKg, goal: userGoal)
            GoalsProvider.save(newGoals)
        }
    }
}
