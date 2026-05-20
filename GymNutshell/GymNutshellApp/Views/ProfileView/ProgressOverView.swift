// ⌘
//  GymNutshell/GymNutshellApp/Views/ProfileView/ProgressOverView.swift
//
//  Propósito: Tela de progresso — mostra dados de desempenho derivados dos registros diários
//             e dos bônus de sequência. Seções: estatísticas de resumo, distribuição por nível,
//             bônus de sequência, atividade, últimos 7 dias, metas ativas e dados físicos.
//             Tocar num dia em "Últimos 7 dias" leva pra aquela data na AchievementsView.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-07.
// ⌘

import SwiftUI
import GymNutshellCore
import SwiftData

// MARK: - Destinos de navegação

private enum StatsDestination: Hashable {
    case goals
    case userGoal
    case physicalData
}

// MARK: - Tela de progresso

/// Tela de progresso. Busca os registros diários e bônus de streak do SwiftData,
/// e compõe cada seção usando componentes de sub-view focados.
struct ProgressOverView: View {

    // MARK: - Dados

    @Query(sort: \DailyRecord.date, order: .forward) private var records: [DailyRecord]
    @Query private var bonuses: [StreakBonus]

    // Campos do perfil necessários pra exibir dados físicos e objetivo fitness.
    @AppStorage(UserProfile.heightKey) private var height: Int = 0
    @AppStorage(UserProfile.ageKey) private var age: Int = 0
    @AppStorage(UserProfile.sexKey) private var sex: String = ""
    @AppStorage(UserProfile.weightKey) private var weight: Double = 0
    @AppStorage(UserProfile.userGoalKey) private var userGoalRaw: String = ""
    @AppStorage(UserProfile.measurementSystemKey) private var measurementSystem: MeasurementSystem = .metric
    @AppStorage(AppTheme.storageKey) private var selectedTheme: AppTheme = .gym
    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color { (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color }

    // Navegação entre abas — compartilhada com a AchievementsView via AppStorage.
    @AppStorage(UserProfile.selectedTabKey) private var selectedTab: Int = 0
    @AppStorage(UserProfile.achievementsSelectedDateKey) private var achievementsDateTimestamp: Double = Date().timeIntervalSince1970
    @AppStorage(UserProfile.achievementsFilterModeKey) private var achievementsFilterMode: String = "day"

    // Contagem de metas ativas — carregada no onAppear pra a stat ficar atualizada.
    @State private var removedItems: Set<String> = []
    @State private var customTrackingGoals: [CustomTrackingGoal] = []
    @State private var showBonusInfoSheet = false
    @State private var showTierSheet = false
    @State private var showNotificationHistory = false
    @State private var navPath = NavigationPath()

    // MARK: - Estatísticas resumidas

    private var totalDays: Int { records.count }

    private var totalPoints: Int {
        let dailyTotal = records.reduce(0) { $0 + $1.points }
        let bonusTotal = bonuses.reduce(0) { $0 + $1.bonusPoints }
        return dailyTotal + bonusTotal
    }

    // MARK: - Distribuição por nível

    // Conta quantos dias completados caem em cada nível de conquista.
    private var level1Days: Int { records.filter { DailyAchievement.from(emoji: $0.achievementEmoji) == .level1 }.count }
    private var level2Days: Int { records.filter { DailyAchievement.from(emoji: $0.achievementEmoji) == .level2 }.count }
    private var level3Days: Int { records.filter { DailyAchievement.from(emoji: $0.achievementEmoji) == .level3 }.count }
    private var level4Days: Int { records.filter { DailyAchievement.from(emoji: $0.achievementEmoji) == .level4 }.count }

    // MARK: - Bônus de streak

    private var weeklyStrongCount:  Int { bonuses.filter { $0.bonusType == "weekly.level3"  }.count }
    private var weeklyExpertCount:  Int { bonuses.filter { $0.bonusType == "weekly.level4"  }.count }
    private var monthlyStrongCount: Int { bonuses.filter { $0.bonusType == "monthly.level3" }.count }
    private var monthlyExpertCount: Int { bonuses.filter { $0.bonusType == "monthly.level4" }.count }

    // MARK: - Atividade

    private var workoutDays: Int { records.filter { $0.didWorkout }.count }
    private var cardioDays:  Int { records.filter { $0.didCardio  }.count }

    // MARK: - Contagem de metas ativas

    // Chaves de rastreio fixas do GoalOrderStore, menos as removidas, mais as metas personalizadas.
    private var activeTrackingCount: Int {
        let builtIn = GoalOrderStore.load().filter { !removedItems.contains($0) }.count
        return builtIn + customTrackingGoals.count
    }


    // MARK: - Últimos 7 dias

    // Cada um dos últimos 7 dias do calendário pareado com seu DailyRecord (ou nil se não registrado).
    private var last7Days: [(date: Date, record: DailyRecord?)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let record = records.first { calendar.startOfDay(for: $0.date) == day }
            return (day, record)
        }
    }

    // MARK: - Label do objetivo fitness

    private var userGoalLabel: String {
        UserGoal(rawValue: userGoalRaw)?.label ?? UserGoal.maintenance.label
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navPath) {
            GeometryReader { geo in
                let isWide = geo.size.width >= 700
                ScrollView {
                    if isWide {
                        // No layout largo, título + sino entram dentro do conteúdo
                        // (capped no mesmo maxWidth) pra alinhar com a borda esquerda
                        // do bloco centralizado, em vez de colar no canto da tela.
                        VStack(alignment: .leading, spacing: 4) {
                            wideTitleBar
                            wideLayout
                        }
                    } else {
                        narrowLayout
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationDestination(for: StatsDestination.self) { dest in
                    switch dest {
                    case .goals:       TrackingGoalsSettingsView()
                    case .userGoal: UserGoalChangeView()
                    case .physicalData: PhysicalDataSettingsView()
                    }
                }
                // Em wide o cabeçalho nativo fica oculto — usamos o customizado
                // dentro do conteúdo. Em narrow segue o comportamento padrão do iOS.
                .toolbar(isWide ? .hidden : .visible, for: .navigationBar)
            }
            .navigationTitle(String(localized: "statistics.title", bundle: .gymNutshellCore))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showNotificationHistory = true
                    } label: {
                        Image(systemName: "bell")
                    }
                    .accessibilityLabel(String(localized: "a11y.notification.history.bell",
                                               bundle: .gymNutshellCore))
                    .accessibilityHint(String(localized: "a11y.notification.history.bell.hint",
                                              bundle: .gymNutshellCore))
                }
            }
        }
        .onAppear {
            removedItems = RemovedItemsStore.load()
            customTrackingGoals = CustomTrackingGoalsStore.load()
        }
        .sheet(isPresented: $showBonusInfoSheet) {
            NavigationStack {
                StreakBonusInfoView(isSheet: true)
            }
        }
        .sheet(isPresented: $showTierSheet) {
            NavigationStack {
                TierInfoView(theme: selectedTheme, sex: sex, isSheet: true)
            }
        }
        .sheet(isPresented: $showNotificationHistory) {
            NotificationHistorySheet()
        }
    }

    // Cabeçalho customizado usado no wideLayout — bell + título alinhados ao
    // mesmo maxWidth (860pt) do conteúdo abaixo, pra terem o mesmo recuo lateral.
    @ViewBuilder
    private var wideTitleBar: some View {
        HStack(spacing: 14) {
            Button {
                showNotificationHistory = true
            } label: {
                Image(systemName: "bell")
                    .font(.title3)
                    // Sino segue accent color — sem foregroundStyle explícito o
                    // `.buttonStyle(.plain)` força a cor primária e o sino fica preto/branco.
                    .foregroundStyle(accentColor)
            }
            .buttonStyle(.plain)
            Text(String(localized: "statistics.title", bundle: .gymNutshellCore))
                .font(.largeTitle.bold())
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .frame(maxWidth: 860)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Layout Narrow (iPhone portrait)

    @ViewBuilder
    private var narrowLayout: some View {
        VStack(spacing: 16) {
            ProfileStatsRow(
                totalDays: totalDays,
                totalPoints: totalPoints,
                bonusCount: bonuses.count,
                onDaysTap: { jumpToAchievements(date: Date()) },
                onBonusTap: { showBonusInfoSheet = true }
            )

            statisticsCard(title: String(localized: "statistics.section.tiers", bundle: .gymNutshellCore)) {
                tierRow(emoji: selectedTheme.emoji(for: .level1, sex: sex), label: selectedTheme.name(for: .level1, sex: sex), days: level1Days)
                accentDivider
                tierRow(emoji: selectedTheme.emoji(for: .level2, sex: sex), label: selectedTheme.name(for: .level2, sex: sex), days: level2Days)
                accentDivider
                tierRow(emoji: selectedTheme.emoji(for: .level3, sex: sex), label: selectedTheme.name(for: .level3, sex: sex), days: level3Days)
                accentDivider
                tierRow(emoji: selectedTheme.emoji(for: .level4, sex: sex), label: selectedTheme.name(for: .level4, sex: sex), days: level4Days)
            }
            .contentShape(Rectangle())
            .onTapGesture { showTierSheet = true }

            statisticsCard(title: String(localized: "statistics.section.bonuses", bundle: .gymNutshellCore)) {
                bonusRow(label: String(localized: "statistics.bonus.weekly.level3", bundle: .gymNutshellCore),  count: weeklyStrongCount)
                accentDivider
                bonusRow(label: String(localized: "statistics.bonus.weekly.level4", bundle: .gymNutshellCore),  count: weeklyExpertCount)
                accentDivider
                bonusRow(label: String(localized: "statistics.bonus.monthly.level3", bundle: .gymNutshellCore), count: monthlyStrongCount)
                accentDivider
                bonusRow(label: String(localized: "statistics.bonus.monthly.level4", bundle: .gymNutshellCore), count: monthlyExpertCount)
            }

            statisticsCard(title: String(localized: "statistics.section.activity", bundle: .gymNutshellCore)) {
                activityRow(emoji: "🏋️", label: String(localized: "statistics.activity.workout", bundle: .gymNutshellCore), days: workoutDays)
                accentDivider
                activityRow(emoji: "🏃", label: String(localized: "statistics.activity.cardio", bundle: .gymNutshellCore),  days: cardioDays)
            }
            .contentShape(Rectangle())
            .onTapGesture { openAchievementsList() }

            statisticsCard(title: String(localized: "statistics.section.goals", bundle: .gymNutshellCore)) {
                goalsRow(label: String(localized: "statistics.goals.active.label", bundle: .gymNutshellCore), count: activeTrackingCount)
            }
            .contentShape(Rectangle())
            .onTapGesture { navPath.append(StatsDestination.goals) }

            if !userGoalRaw.isEmpty {
                statisticsCard(title: String(localized: "statistics.fitness.goal", bundle: .gymNutshellCore)) {
                    HStack {
                        Text(userGoalLabel)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        Spacer()
                    }
                }
                .contentShape(Rectangle())
                .tapButton { navPath.append(StatsDestination.userGoal) }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(localized: "statistics.fitness.goal", bundle: .gymNutshellCore))
                .accessibilityValue(userGoalLabel)
                .accessibilityHint(String(localized: "a11y.stats.card.usergoal.hint", bundle: .gymNutshellCore))
            }

            if height > 0 || weight > 0 || age > 0 || !sex.isEmpty {
                ProfilePhysicalDataView(
                    height: height,
                    weight: weight,
                    age: age,
                    sex: sex,
                    measurementSystem: measurementSystem,
                    accentColor: accentColor
                )
                .contentShape(Rectangle())
                .onTapGesture { navPath.append(StatsDestination.physicalData) }
            }

            ProfileRecentActivityView(
                entries: last7Days,
                selectedTheme: selectedTheme,
                onDayTap: jumpToAchievements(date:)
            )
        }
        .padding()
    }

    // MARK: - Layout Wide (iPad / landscape)

    @ViewBuilder
    private var wideLayout: some View {
        VStack(spacing: 16) {
            // Resumo de pontos — ocupa a largura toda.
            ProfileStatsRow(
                totalDays: totalDays,
                totalPoints: totalPoints,
                bonusCount: bonuses.count,
                onDaysTap: { jumpToAchievements(date: Date()) },
                onBonusTap: { showBonusInfoSheet = true }
            )

            // Dois VStacks alinhados ao topo formam o grid de 2 colunas.
            // Col esquerda: Conquistas → Atividade → Metas Ativas → Objetivo Fitness
            // Col direita:  Bônus de Sequência → Dados Físicos
            HStack(alignment: .top, spacing: 16) {

                // Coluna esquerda
                VStack(spacing: 16) {
                    statisticsCard(title: String(localized: "statistics.section.tiers", bundle: .gymNutshellCore)) {
                        tierRow(emoji: selectedTheme.emoji(for: .level1, sex: sex), label: selectedTheme.name(for: .level1, sex: sex), days: level1Days)
                        accentDivider
                        tierRow(emoji: selectedTheme.emoji(for: .level2, sex: sex), label: selectedTheme.name(for: .level2, sex: sex), days: level2Days)
                        accentDivider
                        tierRow(emoji: selectedTheme.emoji(for: .level3, sex: sex), label: selectedTheme.name(for: .level3, sex: sex), days: level3Days)
                        accentDivider
                        tierRow(emoji: selectedTheme.emoji(for: .level4, sex: sex), label: selectedTheme.name(for: .level4, sex: sex), days: level4Days)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { showTierSheet = true }

                    statisticsCard(title: String(localized: "statistics.section.activity", bundle: .gymNutshellCore)) {
                        activityRow(emoji: "🏋️", label: String(localized: "statistics.activity.workout", bundle: .gymNutshellCore), days: workoutDays)
                        accentDivider
                        activityRow(emoji: "🏃", label: String(localized: "statistics.activity.cardio", bundle: .gymNutshellCore),  days: cardioDays)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { openAchievementsList() }

                    statisticsCard(title: String(localized: "statistics.section.goals", bundle: .gymNutshellCore)) {
                        goalsRow(label: String(localized: "statistics.goals.active.label", bundle: .gymNutshellCore), count: activeTrackingCount)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { navPath.append(StatsDestination.goals) }
                }
                .frame(maxWidth: .infinity)

                // Coluna direita
                VStack(spacing: 16) {
                    statisticsCard(title: String(localized: "statistics.section.bonuses", bundle: .gymNutshellCore)) {
                        bonusRow(label: String(localized: "statistics.bonus.weekly.level3", bundle: .gymNutshellCore),  count: weeklyStrongCount)
                        accentDivider
                        bonusRow(label: String(localized: "statistics.bonus.weekly.level4", bundle: .gymNutshellCore),  count: weeklyExpertCount)
                        accentDivider
                        bonusRow(label: String(localized: "statistics.bonus.monthly.level3", bundle: .gymNutshellCore), count: monthlyStrongCount)
                        accentDivider
                        bonusRow(label: String(localized: "statistics.bonus.monthly.level4", bundle: .gymNutshellCore), count: monthlyExpertCount)
                    }

                    if height > 0 || weight > 0 || age > 0 || !sex.isEmpty {
                        ProfilePhysicalDataView(
                            height: height,
                            weight: weight,
                            age: age,
                            sex: sex,
                            measurementSystem: measurementSystem,
                            accentColor: accentColor
                        )
                        .contentShape(Rectangle())
                        .onTapGesture { navPath.append(StatsDestination.physicalData) }
                    }
                }
                .frame(maxWidth: .infinity)
            }

            // Objetivo fitness — largura toda, centralizado, abaixo das duas colunas.
            if !userGoalRaw.isEmpty {
                statisticsCardCentered(title: String(localized: "statistics.fitness.goal", bundle: .gymNutshellCore)) {
                    Text(userGoalLabel)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .contentShape(Rectangle())
                .tapButton { navPath.append(StatsDestination.userGoal) }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(localized: "statistics.fitness.goal", bundle: .gymNutshellCore))
                .accessibilityValue(userGoalLabel)
                .accessibilityHint(String(localized: "a11y.stats.card.usergoal.hint", bundle: .gymNutshellCore))
            }

            // Últimos 7 dias — ocupa a largura toda, abaixo das duas colunas.
            ProfileRecentActivityView(
                entries: last7Days,
                selectedTheme: selectedTheme,
                onDayTap: jumpToAchievements(date:)
            )
        }
        .padding()
        .frame(maxWidth: 860)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Navegação

    // Navega pra AchievementsView na data indicada atualizando o estado compartilhado no AppStorage.
    private func jumpToAchievements(date: Date) {
        achievementsDateTimestamp = date.timeIntervalSince1970
        achievementsFilterMode = "day"
        selectedTab = MainView.Tab.achievements
    }

    // Abre a AchievementsView no modo lista (sem filtro por dia).
    private func openAchievementsList() {
        achievementsFilterMode = "all"
        selectedTab = MainView.Tab.achievements
    }

    // MARK: - Divisória colorida com a cor de destaque do usuário

    private var accentDivider: some View {
        Rectangle()
            .fill(accentColor.opacity(0.25))
            .frame(height: 1)
            .padding(.leading, 16)
    }

    // MARK: - Construtor de card

    // Envolve uma lista de linhas num card com cabeçalho de seção — mesmo estilo visual da ProfilePhysicalDataView.
    @ViewBuilder
    private func statisticsCard(title: String, @ViewBuilder rows: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)
            Rectangle()
                .fill(accentColor.opacity(0.25))
                .frame(height: 1)
            rows()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // Variante centralizada do card de estatísticas — título e conteúdo centralizados horizontalmente.
    @ViewBuilder
    private func statisticsCardCentered(title: String, @ViewBuilder rows: () -> some View) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)
            Rectangle()
                .fill(accentColor.opacity(0.25))
                .frame(height: 1)
            rows()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - Construtores de linhas

    private func tierRow(emoji: String, label: String, days: Int) -> some View {
        HStack {
            Text(emoji)
                .accessibilityHidden(true)
            Text(label)
            Spacer()
            Text(String(format: String(localized: "statistics.tier.days", bundle: .gymNutshellCore), days))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.stats.tier.row.format",
                                                 bundle: .gymNutshellCore), label, days))
    }

    private func bonusRow(label: String, count: Int) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(String(format: String(localized: "statistics.bonus.times", bundle: .gymNutshellCore), count))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .tapButton { showBonusInfoSheet = true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.stats.bonus.row.format",
                                                 bundle: .gymNutshellCore), label, count))
        .accessibilityHint(String(localized: "a11y.record.bonus.hint", bundle: .gymNutshellCore))
    }

    private func activityRow(emoji: String, label: String, days: Int) -> some View {
        HStack {
            Text(emoji)
                .accessibilityHidden(true)
            Text(label)
            Spacer()
            Text(String(format: String(localized: "statistics.tier.days", bundle: .gymNutshellCore), days))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.stats.activity.row.format",
                                                 bundle: .gymNutshellCore), label, days))
    }

    private func goalsRow(label: String, count: Int) -> some View {
        HStack {
            Text("✅")
                .accessibilityHidden(true)
            Text(label)
            Spacer()
            Text(String(format: String(localized: "statistics.goals.active", bundle: .gymNutshellCore), count))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: String(localized: "a11y.stats.goals.row.format",
                                                 bundle: .gymNutshellCore), label, count))
    }
}

#Preview {
    ProgressOverView()
        .modelContainer(for: [DailyRecord.self, StreakBonus.self], inMemory: true)
}
