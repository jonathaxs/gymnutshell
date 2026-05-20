// ⌘
//  GymNutshell/GymNutshellApp/Views/WelcomeView/WelcomeView.swift
//
//  Propósito: Onboarding em múltiplas etapas que coleta o perfil do usuário e calcula as metas diárias.
//             Dona do estado e faz a navegação entre as views de cada etapa.
//             Etapas: início → objetivo → dados físicos (inclui nome) → tema → resumo.
//
//  Created by Jonathas Motta (@jonathaxs) on 2025-11-24.
// ⌘

import SwiftUI
import GymNutshellCore
import SwiftData
import UniformTypeIdentifiers

/// Tela de onboarding multi-etapas mostrada só no primeiro lançamento.
/// Coleta objetivo fitness, dados físicos e nome,
/// depois calcula e persiste as metas diárias do usuário.
///
/// Cada etapa fica no próprio arquivo dentro de Views/WelcomeView/.
struct WelcomeView: View {

    // MARK: - Callback de conclusão

    /// Chamado quando o usuário termina o onboarding pra o GymNutshellApp trocar pra MainView.
    let onComplete: () -> Void

    // Contexto de dados — necessário pra restauração de backup via painel esquerdo no modo wide.
    @Environment(\.modelContext) private var modelContext

    // Estado de importação do painel esquerdo (modo wide — etapa inicial).
    @State private var isPanelImporting: Bool = false
    @State private var panelRestoreError: String? = nil

    // MARK: - Controle de etapas
    // O enum WelcomeStep + textos de painel ficam em WelcomeStep.swift.

    @State private var currentStep: WelcomeStep

    // MARK: - Init

    init(onComplete: @escaping () -> Void) {
        _currentStep = State(initialValue: .start)
        self.onComplete = onComplete
    }

    // Controla a direção da navegação pra a animação de slide funcionar certo.
    @State private var isGoingForward: Bool = true

    // MARK: - Sistema de medidas

    // Detectado a partir do locale do device no início do onboarding.
    // O usuário pode mudar essa escolha depois em Settings.
    @State private var measurementSystem: MeasurementSystem = MeasurementSystemStore.detectDefault()

    // MARK: - Seleção de tema

    // O tema de mascote escolhido no onboarding. Padrão é Academia.
    // Persistido no final de finishOnboarding() pra todo o app atualizar imediatamente.
    @State private var onboardingTheme: AppTheme = .gym

    // MARK: - Campos em edição

    @State private var name: String = ""
    @State private var weightText: String = ""        // kg (metric) ou lbs (US)
    @State private var weightStonesText: String = "" // stones — usado no UK
    @State private var weightStoneLbsText: String = "" // lbs restante (0–13) — usado no UK
    @State private var heightText: String = ""       // cm — usado no metric
    @State private var heightFeetText: String = ""   // feet — usado no US ou UK
    @State private var heightInchesText: String = "" // inches — usado no US ou UK
    @State private var birthday: Date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2001, month: 1, day: 1)) ?? Date()
    @State private var sex: String = "male"
    @State private var userGoal: UserGoal = .maintenance

    // MARK: - Seleções de metas opcionais

    // Se o usuário escolheu incluir Good Fat no rastreio.
    @State private var includeFats: Bool = false
    // Se o usuário escolheu incluir as metas de check-in Creatine e Vitamin D.
    @State private var includeCreatine: Bool = false
    @State private var includeVitaminD: Bool = false

    // MARK: - Resultado calculado exibido na etapa de resumo

    @State private var calculatedGoals: GoalsCalculator.Result? = nil
    @State private var summaryScrolledToEnd = false

    // MARK: - Validações

    private var isPhysicalStepValid: Bool {
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
            // Peso: stones >= 1; lbs restante 0–13.
            guard let stones = Int(weightStonesText), stones >= 1 else { return false }
            let stoneLbs = Int(weightStoneLbsText) ?? 0
            guard stoneLbs >= 0, stoneLbs < 14 else { return false }
            // Altura igual ao US.
            guard let feet = Int(heightFeetText), feet > 0 else { return false }
            let inches = Int(heightInchesText) ?? 0
            guard inches >= 0, inches < 12 else { return false }
        }
        return true
    }

    // MARK: - Ações

    private func advance() {
        isGoingForward = true
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentStep {
            case .start:
                currentStep = .goal
            case .goal:
                currentStep = .physicalData
            case .physicalData:
                summaryScrolledToEnd = false
                // Converte peso pra kg antes de calcular, já que GoalsCalculator sempre espera kg.
                let weightKg: Double
                switch measurementSystem {
                case .metric: weightKg = Double(weightText) ?? 70
                case .us:     weightKg = UnitConverter.lbsToKg(Double(weightText) ?? 154)
                case .uk:
                    let st = Int(weightStonesText) ?? 11
                    let lb = Int(weightStoneLbsText) ?? 0
                    weightKg = UnitConverter.stoneLbsToKg(stones: st, lbs: lb)
                }
                calculatedGoals = GoalsCalculator.calculate(weightKg: weightKg, goal: userGoal)
                currentStep = .summary
            case .summary:
                currentStep = .theme
            case .theme:
                finishOnboarding()
            }
        }
    }

    private func goBack() {
        guard let prev = WelcomeStep(rawValue: currentStep.rawValue - 1) else { return }
        isGoingForward = false
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = prev
        }
    }

    private func finishOnboarding() {
        let defaults = UserDefaults.standard
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // Converte os valores exibidos pro usuário pra metric antes de salvar.
        // O armazenamento é sempre em kg e cm — a conversão acontece só na camada de UI.
        let weightKg: Double
        let heightCm: Int

        switch measurementSystem {
        case .metric:
            weightKg = Double(weightText) ?? 70
            heightCm = Int(heightText) ?? 170
        case .us:
            weightKg = UnitConverter.lbsToKg(Double(weightText) ?? 154)
            let feet   = Int(heightFeetText) ?? 5
            let inches = Int(heightInchesText) ?? 8
            heightCm = UnitConverter.feetAndInchesToCm(feet: feet, inches: inches)
        case .uk:
            let st = Int(weightStonesText) ?? 11
            let lb = Int(weightStoneLbsText) ?? 0
            weightKg = UnitConverter.stoneLbsToKg(stones: st, lbs: lb)
            let feet   = Int(heightFeetText) ?? 5
            let inches = Int(heightInchesText) ?? 8
            heightCm = UnitConverter.feetAndInchesToCm(feet: feet, inches: inches)
        }

        // Persiste os dados do perfil.
        defaults.set(trimmedName,              forKey: UserProfile.nameKey)
        defaults.set(weightKg,                 forKey: UserProfile.weightKey)
        defaults.set(heightCm,                 forKey: UserProfile.heightKey)
        defaults.set(birthday.timeIntervalSince1970,   forKey: UserProfile.birthdayKey)
        defaults.set(UserProfile.age(from: birthday),  forKey: UserProfile.ageKey)
        defaults.set(sex,                      forKey: UserProfile.sexKey)
        defaults.set(userGoal.rawValue,     forKey: UserProfile.userGoalKey)
        // Persiste o sistema de medidas escolhido no onboarding.
        defaults.set(measurementSystem.rawValue, forKey: UserProfile.measurementSystemKey)
        // Persiste o tema de mascote escolhido no onboarding.
        defaults.set(onboardingTheme.rawValue, forKey: AppTheme.storageKey)
        // Persiste a cor de destaque padrão baseada no sexo escolhido.
        // O usuário pode sobrescrever em Settings > Cores.
        defaults.set(AppAccentColor.defaultForSex(sex).rawValue, forKey: AppAccentColor.storageKey)

        // Persiste as metas calculadas pra o GoalsProvider pegar imediatamente.
        if let goals = calculatedGoals {
            GoalsProvider.save(goals)
        }

        // Marca metas opcionais de rastreio como removidas se o usuário não incluiu.
        if !includeFats  { RemovedItemsStore.remove("tracking.goodFat") }

        // Marca metas opcionais de suplementos como removidas se o usuário não incluiu.
        if !includeCreatine { RemovedItemsStore.remove("tracking.creatine") }
        if !includeVitaminD { RemovedItemsStore.remove("tracking.vitaminD") }

        // Marca o onboarding como concluído.
        defaults.set(true, forKey: UserProfile.didCompleteOnboardingKey)

        onComplete()
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            if geo.size.width >= 700 {
                // Landscape / iPad: painel contextual à esquerda, conteúdo da etapa à direita.
                HStack(spacing: 0) {
                    contextPanel
                        .frame(width: 340)
                    Divider()
                    stepContent(isWide: true)
                        .frame(maxWidth: .infinity)
                }
            } else {
                // Portrait / iPhone: layout original com largura limitada.
                stepContent(isWide: false)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Painel contextual (wide layout) — emoji + título + botões da etapa atual

    @ViewBuilder
    private var contextPanel: some View {
        VStack(spacing: 0) {
            // Emoji + título — anima junto com a transição de etapa.
            VStack(spacing: 16) {
                Spacer()
                Text(currentStep.panelEmoji)
                    .font(.system(size: 64))
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                    // Emoji decorativo — título logo abaixo já comunica a etapa.
                    .accessibilityHidden(true)
                Text(currentStep.panelTitle)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                if let subtitle = currentStep.panelSubtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal)

            // Botões de ação — variam conforme a etapa.
            VStack(spacing: 12) {
                if currentStep == .start {
                    Button(action: advance) {
                        Text(String(localized: "welcome.start.new", bundle: .gymNutshellCore))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(sexColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    Button { isPanelImporting = true } label: {
                        Text(String(localized: "welcome.start.restore", bundle: .gymNutshellCore))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(sexColor.opacity(0.15))
                            .foregroundStyle(sexColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                } else {
                    continueButton

                    Button(action: goBack) {
                        Text(String(localized: "welcome.button.back", bundle: .gymNutshellCore))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .fileImporter(isPresented: $isPanelImporting, allowedContentTypes: [.json]) { result in
            if case .success(let url) = result { panelPerformRestore(from: url) }
        }
        .alert(
            String(localized: "settings.backup.error.title", bundle: .gymNutshellCore),
            isPresented: .init(get: { panelRestoreError != nil }, set: { if !$0 { panelRestoreError = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let msg = panelRestoreError { Text(msg) }
        }
    }

    // Restaura backup a partir de um arquivo selecionado no painel wide.
    private func panelPerformRestore(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            panelRestoreError = "Could not access the selected file."
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        do {
            let data = try Data(contentsOf: url)
            let payload = try BackupManager.decode(data)
            try BackupManager.applyPayload(payload, into: modelContext)
            UserDefaults.standard.set(true, forKey: UserProfile.didCompleteOnboardingKey)
            onComplete()
        } catch {
            panelRestoreError = error.localizedDescription
        }
    }

    // MARK: - Conteúdo da etapa (progress bar + step + botões opcionais)

    @ViewBuilder
    private func stepContent(isWide: Bool) -> some View {
        VStack(spacing: 0) {

            // Botão de voltar e barra de progresso no topo.
            HStack(spacing: 12) {
                // Botão de voltar — escondido na primeira etapa e no modo wide (botões ficam no painel).
                if currentStep != .start && !isWide {
                    Button(action: goBack) {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "a11y.welcome.back.button",
                                               bundle: .gymNutshellCore))
                }

                progressBar
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // Conteúdo da etapa com transição de slide.
            Group {
                switch currentStep {
                case .start:
                    WelcomeStartStep(
                        onRestore: onComplete,
                        onNewProfile: advance,
                        isWide: isWide
                    )
                case .goal:
                    WelcomeUserGoalStep(userGoal: $userGoal, isWide: isWide)
                case .physicalData:
                    WelcomePhysicalDataStep(
                        measurementSystem: measurementSystem,
                        weightText: $weightText,
                        weightStonesText: $weightStonesText,
                        weightStoneLbsText: $weightStoneLbsText,
                        heightText: $heightText,
                        heightFeetText: $heightFeetText,
                        heightInchesText: $heightInchesText,
                        birthday: $birthday,
                        sex: $sex,
                        isWide: isWide,
                        onContinue: advance,
                        onBack: goBack,
                        isFormValid: isPhysicalStepValid,
                        buttonColor: sexColor
                    )
                case .summary:
                    WelcomeSummaryStep(
                        goals: calculatedGoals,
                        measurementSystem: measurementSystem,
                        userGoal: userGoal,
                        accentColor: sexColor,
                        includeFats: $includeFats,
                        includeCreatine: $includeCreatine,
                        includeVitaminD: $includeVitaminD,
                        scrolledToEnd: $summaryScrolledToEnd,
                        isWide: isWide
                    )
                case .theme:
                    WelcomeThemeStep(selectedTheme: $onboardingTheme, sex: sex, accentColor: sexColor, isWide: isWide)
                }
            }
            .frame(maxHeight: .infinity)
            .transition(.asymmetric(
                insertion: .move(edge: isGoingForward ? .trailing : .leading),
                removal: .move(edge: isGoingForward ? .leading : .trailing)
            ))
            .animation(.easeInOut(duration: 0.3), value: currentStep)

            // Botões de rodapé — só no modo narrow e fora do physicalData (que tem botões inline).
            if currentStep != .start && currentStep != .physicalData && !isWide {
                VStack(spacing: 8) {
                    continueButton

                    Button(action: goBack) {
                        Text(String(localized: "welcome.button.back", bundle: .gymNutshellCore))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        // O VStack externo ignora a safe area do teclado: os botões ficam fixos na base,
        // o ScrollView interno de cada etapa ajusta seu contentInset pra mostrar os campos.
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Barra de progresso

    private var progressBar: some View {
        let total = WelcomeStep.allCases.count
        let current = currentStep.rawValue + 1

        return HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index < current ? sexColor : Color.secondary.opacity(0.3))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        // Capsules são puramente visuais — colapsa tudo num único elemento
        // de a11y que anuncia "Passo X de Y".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: String(localized: "a11y.welcome.progress.format",
                                                 bundle: .gymNutshellCore), current, total))
    }

    // MARK: - Cores dinâmicas

    // Cor de destaque baseada no sexo selecionado.
    private var sexColor: Color {
        switch sex {
        case "female": return .purple
        case "male":   return .blue
        default:       return .yellow
        }
    }

    // Cor do botão Continuar: segue o objetivo na etapa de goal, e o sexo nas demais.
    private var continueButtonColor: Color {
        switch currentStep {
        case .goal:
            switch userGoal {
            case .bulking:     return .orange
            case .maintenance: return Color.accentColor
            case .cutting:     return .green
            }
        case .physicalData, .summary, .theme:
            return sexColor
        default:
            return Color.accentColor
        }
    }

    // MARK: - Botão continuar

    private var isCurrentStepValid: Bool {
        switch currentStep {
        case .start:        return true
        case .goal:         return true
        case .physicalData: return isPhysicalStepValid
        case .summary:      return summaryScrolledToEnd
        case .theme:        return true
        }
    }

    private var continueButtonLabel: String {
        currentStep == .theme
            ? String(localized: "welcome.button.start", bundle: .gymNutshellCore)
            : String(localized: "welcome.button.continue", bundle: .gymNutshellCore)
    }

    private var continueButton: some View {
        Button(action: advance) {
            Text(continueButtonLabel)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(continueButtonColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isCurrentStepValid)
        .opacity(isCurrentStepValid ? 1.0 : 0.5)
    }
}

#Preview {
    WelcomeView(onComplete: {})
}
