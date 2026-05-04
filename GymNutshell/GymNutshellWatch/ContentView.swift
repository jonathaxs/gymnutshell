// ⌘
//  GymNutshellWatch/ContentView.swift
//
//  Propósito: Tela principal do Watch app — hero superior com anel de progresso médio
//             e nome do nível. Embaixo, cards de metas com fundo preenchendo conforme
//             o progresso. Tap num card expande os botões − / + abaixo dele.
//             A lista de metas respeita a ordem e a configuração de remoção definidas
//             no iPhone (via GoalOrderStore / RemovedItemsStore).
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-26.
// ⌘

import SwiftUI
import WatchKit
import WidgetKit
import GymNutshellCore

struct ContentView: View {

    // MARK: - Ingestões (chaves alinhadas com o iPhone pra facilitar o sync futuro)

    @AppStorage("workoutIntake")  private var workoutIntake:  Int = 0
    @AppStorage("cardioIntake")   private var cardioIntake:   Int = 0
    @AppStorage("sleepHours")     private var sleepHours:     Int = 0
    @AppStorage("waterIntake")    private var waterIntake:    Int = 0
    @AppStorage("proteinIntake")  private var proteinIntake:  Int = 0
    @AppStorage("carbIntake")     private var carbIntake:     Int = 0
    @AppStorage("goodFatIntake")  private var goodFatIntake:  Int = 0
    @AppStorage("fiberIntake")    private var fiberIntake:    Int = 0
    @AppStorage("creatineIntake") private var creatineIntake: Int = 0
    @AppStorage("vitaminDIntake") private var vitaminDIntake: Int = 0

    // MARK: - Preferências

    @AppStorage(AppTheme.storageKey)              private var storedThemeRaw:       String = AppTheme.gym.rawValue
    @AppStorage(UserProfile.sexKey)               private var sex:                  String = "male"
    @AppStorage(AppAccentColor.storageKey)        private var storedColorRaw:       String = AppAccentColor.blue.rawValue
    @AppStorage(GoalCategory.vitaminDCategoryKey) private var vitaminDCategoryRaw:  String = GoalCategory.vitamina.rawValue

    // Valores-alvo das metas — observados como @AppStorage pra que SwiftUI
    // re-renderize quando o iPhone mandar novos valores via WatchConnectivity.
    @AppStorage("tracking.workout")  private var workoutGoalValue:  Int = DefaultGoals.workout
    @AppStorage("tracking.cardio")   private var cardioGoalValue:   Int = DefaultGoals.cardio
    @AppStorage("tracking.sleep")    private var sleepGoalValue:    Int = DefaultGoals.sleep
    @AppStorage("tracking.water")    private var waterGoalValue:    Int = DefaultGoals.water
    @AppStorage("tracking.protein")  private var proteinGoalValue:  Int = DefaultGoals.protein
    @AppStorage("tracking.carbs")    private var carbsGoalValue:    Int = DefaultGoals.carbs
    @AppStorage("tracking.goodFat")  private var goodFatGoalValue:  Int = DefaultGoals.goodFat
    @AppStorage("tracking.fiber")    private var fiberGoalValue:    Int = DefaultGoals.fiber
    @AppStorage("tracking.creatine") private var creatineGoalValue: Int = DefaultGoals.creatine
    @AppStorage("tracking.vitaminD") private var vitaminDGoalValue: Int = DefaultGoals.vitaminD

    // Trigger de refresh — quando UserDefaults muda (incluindo a ordem de metas
    // ou removedItems), incrementa pra forçar re-render do goalEntries (que é
    // computed property baseada em GoalOrderStore.load() / RemovedItemsStore.load()).
    @State private var refreshTick: Int = 0

    // Toggles de "dia de descanso" — sincronizam iPhone ↔ Watch via WatchConnectivity.
    @AppStorage("workoutRestDay") private var workoutRestDay: Bool = false
    @AppStorage("cardioRestDay")  private var cardioRestDay:  Bool = false

    @State private var expandedId: String?

    private var theme: AppTheme            { AppTheme(rawValue: storedThemeRaw) ?? .gym }
    private var accent: AppAccentColor     { AppAccentColor(rawValue: storedColorRaw) ?? .blue }
    private var vitaminDCategory: GoalCategory { GoalCategory(rawValue: vitaminDCategoryRaw) ?? .vitamina }

    // MARK: - Metas exibidas

    /// Constrói uma entrada `GoalEntry` a partir de uma chave do GoalOrderStore.
    /// Retorna nil se a chave não for reconhecida (defesa contra dados corrompidos).
    private func entry(forTrackingKey key: String) -> GoalEntry? {
        switch key {
        case "tracking.workout":
            return GoalEntry(
                id: key, emoji: "🏋️", current: workoutIntake, goal: workoutGoalValue,
                unit: "min", increment: DefaultGoals.workoutIncrement,
                update: { workoutIntake = $0 }
            )
        case "tracking.cardio":
            return GoalEntry(
                id: key, emoji: "🏃", current: cardioIntake, goal: cardioGoalValue,
                unit: "min", increment: DefaultGoals.cardioIncrement,
                update: { cardioIntake = $0 }
            )
        case "tracking.sleep":
            return GoalEntry(
                id: key, emoji: "💤", current: sleepHours, goal: sleepGoalValue,
                unit: "h", increment: 1,
                update: { sleepHours = $0 }
            )
        case "tracking.water":
            return GoalEntry(
                id: key, emoji: "💧", current: waterIntake, goal: waterGoalValue,
                unit: "ml", increment: 250,
                update: { waterIntake = $0 }
            )
        case "tracking.protein":
            return GoalEntry(
                id: key, emoji: "🍗", current: proteinIntake, goal: proteinGoalValue,
                unit: "g", increment: 5,
                update: { proteinIntake = $0 }
            )
        case "tracking.carbs":
            return GoalEntry(
                id: key, emoji: "🍞", current: carbIntake, goal: carbsGoalValue,
                unit: "g", increment: 10,
                update: { carbIntake = $0 }
            )
        case "tracking.goodFat":
            return GoalEntry(
                id: key, emoji: "🧈", current: goodFatIntake, goal: goodFatGoalValue,
                unit: "g", increment: 5,
                update: { goodFatIntake = $0 }
            )
        case "tracking.fiber":
            return GoalEntry(
                id: key, emoji: "🌾", current: fiberIntake, goal: fiberGoalValue,
                unit: "g", increment: 5,
                update: { fiberIntake = $0 }
            )
        case "tracking.creatine":
            return GoalEntry(
                id: key, emoji: "🧪", current: creatineIntake, goal: creatineGoalValue,
                unit: "g", increment: DefaultGoals.creatineIncrement,
                update: { creatineIntake = $0 }
            )
        case "tracking.vitaminD":
            return GoalEntry(
                id: key, emoji: "☀️", current: vitaminDIntake, goal: vitaminDGoalValue,
                unit: GoalCategory.vitaminDUnit(for: vitaminDCategory),
                increment: GoalCategory.vitaminDIncrement(for: vitaminDCategory),
                update: { vitaminDIntake = $0 }
            )
        default:
            return nil
        }
    }

    /// Lista final de metas a exibir — respeita:
    ///   1. Ordem das categorias (`GoalCategoryOrderStore`) — mesma escolhida em
    ///      App Settings → Goals → Categories.
    ///   2. Dentro de cada categoria, ordem das metas (`GoalOrderStore`).
    ///   3. Filtro de itens removidos (`RemovedItemsStore`).
    ///
    /// Acessa `refreshTick` pra que SwiftUI saiba que precisa recalcular quando
    /// o iPhone mandar uma nova ordem via WatchConnectivity.
    private var goalEntries: [GoalEntry] {
        _ = refreshTick // dependência explícita pro SwiftUI
        let removed = RemovedItemsStore.load()
        let allKeys = GoalOrderStore.load().filter { !removed.contains($0) }
        let categoryOrder = GoalCategoryOrderStore.load()

        var result: [GoalEntry] = []
        var usedKeys = Set<String>()

        // Itera categoria por categoria — dentro de cada uma, mantém ordem do GoalOrderStore.
        for category in categoryOrder {
            for key in allKeys where !usedKeys.contains(key) {
                let effective = GoalCategory.effectiveCategory(for: key, vitaminDCategory: vitaminDCategory)
                guard effective == category else { continue }
                if let entry = entry(forTrackingKey: key) {
                    result.append(entry)
                    usedKeys.insert(key)
                }
            }
        }

        // Defesa: chaves sem categoria reconhecida vão pro final.
        for key in allKeys where !usedKeys.contains(key) {
            if let entry = entry(forTrackingKey: key) {
                result.append(entry)
            }
        }

        return result
    }

    private var averageProgress: Double {
        // Usa o MESMO algoritmo que o iPhone (WidgetSnapshot.buildCurrent), só que
        // executado localmente sobre o UserDefaults do Watch. Garante:
        //  - Paridade exata de % com iPhone (mesmo set de chaves, mesma ordem, mesma matemática)
        //  - Atualização imediata ao incrementar metas no Watch (cálculo local, não depende
        //    do snapshot que vem do iPhone).
        // refreshTick força SwiftUI a recomputar quando UserDefaults muda.
        _ = refreshTick
        return WidgetSnapshot.buildCurrent().progressNormalized
    }

    private var tier: DailyAchievement { DailyAchievement.from(progress: averageProgress) }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                hero
                    .padding(.bottom, 4)

                ForEach(goalEntries) { entry in
                    goalCard(entry)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UserDefaults.didChangeNotification,
            object: UserDefaults.standard
        )) { _ in
            // Filtra por UserDefaults.standard — sem isso, o save abaixo (que escreve
            // no App Group) dispara outra notificação e cai num loop infinito que trava
            // o app no carregamento.
            refreshTick &+= 1
            // Recalcula snapshot localmente e atualiza o widget do Watch — assim o
            // progresso na complication acompanha incrementos feitos no próprio Watch
            // (não depende mais do iPhone enviar de volta).
            WidgetSnapshotStore.save(WidgetSnapshot.buildCurrent())
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    // MARK: - Hero

    // Cor do anel acompanha o tier do dia, igual TodayProgressRingView do iPhone:
    // <30% vermelho (just starting), <60% laranja (on your way),
    // <100% verde (almost there), 100% azul (goal complete).
    private var ringColor: Color {
        switch averageProgress {
        case ..<0.30: return .red
        case ..<0.60: return .orange
        case ..<1.0:  return .green
        default:      return .blue
        }
    }

    private var hero: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: averageProgress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: averageProgress)

                Text(theme.emoji(for: tier, sex: sex))
                    .font(.system(size: 36))
            }
            .frame(width: 100, height: 100)

            Text(theme.name(for: tier, sex: sex))
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            Text("\(Int(averageProgress * 100))%")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(ringColor)
        }
    }

    // MARK: - Goal card

    @ViewBuilder
    private func goalCard(_ entry: GoalEntry) -> some View {
        let isExpanded = expandedId == entry.id

        VStack(spacing: 6) {
            cardHeader(entry, isExpanded: isExpanded)

            if isExpanded {
                cardControls(entry)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func cardHeader(_ entry: GoalEntry, isExpanded: Bool) -> some View {
        let progress = ProgressHelpers.normalizedProgress(current: entry.current, goal: entry.goal)
        let tier = DailyAchievement.from(progress: progress)
        let fillColor = tier.color.opacity(0.55)
        let restActive = restDayActive(for: entry.id)

        return ZStack(alignment: .leading) {
            // Fundo cinza ocupando a largura total.
            Color.secondary.opacity(0.18)

            // Preenchimento proporcional — Rectangle clipado pelo Capsule externo
            // garante que mesmo com largura pequena o fill respeite a curva da pílula.
            GeometryReader { geo in
                Rectangle()
                    .fill(fillColor)
                    .frame(width: geo.size.width * progress)
                    .animation(.easeInOut(duration: 0.25), value: progress)
                    .animation(.easeInOut(duration: 0.25), value: fillColor)
            }

            HStack(spacing: 8) {
                Text(entry.emoji)
                    .font(.title3)
                if restActive == true {
                    Text(String(localized: "today.restday.label", bundle: .gymNutshellCore))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(entry.current) / \(entry.goal) \(entry.unit)")
                        .font(.caption.monospacedDigit().weight(.semibold))
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(Capsule())
        .contentShape(Capsule())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.22)) {
                expandedId = isExpanded ? nil : entry.id
            }
        }
    }

    @ViewBuilder
    private func cardControls(_ entry: GoalEntry) -> some View {
        let restActive = restDayActive(for: entry.id)

        HStack(spacing: 8) {
            // Botão ON/OFF — só pra metas que suportam dia de descanso.
            if restActive != nil {
                onOffButton(for: entry.id, isOn: restActive == true)
            }

            if restActive == true {
                // Dia de descanso ativo: − e + somem, mostra "Day off" no espaço deles.
                Text(String(localized: "today.restday.label", bundle: .gymNutshellCore))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 36)
            } else {
                Button {
                    let next = max(entry.current - entry.increment, 0)
                    entry.update(next)
                    WKInterfaceDevice.current().play(.click)
                    WatchConnectivityManager.shared.sendIntakeUpdate(key: storageKey(for: entry.id), value: next)
                } label: {
                    Image(systemName: "minus")
                        .font(.body.weight(.bold))
                        .frame(maxWidth: .infinity, minHeight: 36)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(accent.color)
                .disabled(entry.current <= 0)

                Button {
                    let next = min(entry.current + entry.increment, entry.goal)
                    entry.update(next)
                    WKInterfaceDevice.current().play(next >= entry.goal ? .success : .click)
                    WatchConnectivityManager.shared.sendIntakeUpdate(key: storageKey(for: entry.id), value: next)
                } label: {
                    Image(systemName: "plus")
                        .font(.body.weight(.bold))
                        .frame(maxWidth: .infinity, minHeight: 36)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(accent.color)
                .disabled(entry.current >= entry.goal)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    private func onOffButton(for goalId: String, isOn: Bool) -> some View {
        Button {
            toggleRestDay(for: goalId)
            WKInterfaceDevice.current().play(.click)
        } label: {
            Text(isOn ? "ON" : "OFF")
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity, minHeight: 36)
                .foregroundStyle(isOn ? Color.white : accent.color)
                .background(
                    Capsule().fill(isOn ? accent.color : Color.secondary.opacity(0.25))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Rest day helpers

    /// Retorna o estado atual do toggle de "dia de descanso" pra metas que suportam,
    /// ou nil pras que não suportam (não mostra ON/OFF).
    private func restDayActive(for goalId: String) -> Bool? {
        switch goalId {
        case "tracking.workout": return workoutRestDay
        case "tracking.cardio":  return cardioRestDay
        default:                 return nil
        }
    }

    /// Inverte o toggle de "dia de descanso" da meta.
    private func toggleRestDay(for goalId: String) {
        switch goalId {
        case "tracking.workout": workoutRestDay.toggle()
        case "tracking.cardio":  cardioRestDay.toggle()
        default: break
        }
    }

    /// Mapeia o id do GoalEntry (que é a chave do GoalOrderStore, ex: "tracking.water")
    /// para a chave do UserDefaults usada pra persistir a ingestão (ex: "waterIntake").
    private func storageKey(for goalId: String) -> String {
        switch goalId {
        case "tracking.workout":  return "workoutIntake"
        case "tracking.cardio":   return "cardioIntake"
        case "tracking.sleep":    return "sleepHours"
        case "tracking.water":    return "waterIntake"
        case "tracking.protein":  return "proteinIntake"
        case "tracking.carbs":    return "carbIntake"
        case "tracking.goodFat":  return "goodFatIntake"
        case "tracking.fiber":    return "fiberIntake"
        case "tracking.creatine": return "creatineIntake"
        case "tracking.vitaminD": return "vitaminDIntake"
        default:                  return goalId
        }
    }
}

// MARK: - GoalEntry

/// Modelo leve só pra listar as metas no Watch — não persiste, é construído a cada render.
private struct GoalEntry: Identifiable {
    let id: String
    let emoji: String
    let current: Int
    let goal: Int
    let unit: String
    let increment: Int
    let update: (Int) -> Void
}

#Preview {
    ContentView()
}
