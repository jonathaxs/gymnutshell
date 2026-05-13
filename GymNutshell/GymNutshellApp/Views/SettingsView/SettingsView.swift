// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/SettingsView.swift
//
//  Propósito: Tela raiz de settings. Contém links pra edição de perfil, gerenciamento de metas
//             e preferências do app. Mostra as infos de versão como rodapé.
//
//  Created by Jonathas Motta (@jonathaxs) on 2025-11-24.
// ⌘

import SwiftUI
import GymNutshellCore

struct SettingsView: View {
    // Cor de destaque e tema — usados pra colorir ícones e passar ao TierInfoView.
    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    @AppStorage(AppTheme.storageKey) private var selectedTheme: AppTheme = .gym
    @AppStorage(UserProfile.sexKey) private var sex: String = "male"

    // Usado pelo botão "Idioma" pra abrir Ajustes do iOS na página do Gym Nutshell.
    @Environment(\.openURL) private var openURL

    private var accentColor: AppAccentColor {
        AppAccentColor(rawValue: storedColorRaw) ?? .blue
    }

    // Usado pelo deep-link da notificação "Backup do iCloud" pra empurrar a BackupSettingsView.
    @State private var showBackup: Bool = false

    @State private var showNotificationHistory: Bool = false

    var body: some View {
        // GeometryReader detecta a largura disponível pra forçar o split no iPhone landscape (≥700 pt).
        // NavigationSplitView respeita horizontalSizeClass; ao sobrescrever pra .regular em telas largas
        // o split é exibido mesmo no iPhone landscape — onde o size class nativo ainda seria .compact.
        GeometryReader { geo in
        NavigationSplitView {
            // Sidebar: lista de seções de settings.
            List {
                // Seção Perfil — dados físicos, objetivo fitness e metas do usuário.
                Section(header: Text(String(localized: "settings.section.edit", bundle: .gymNutshellCore)).foregroundStyle(accentColor.color)) {
                    NavigationLink {
                        PhysicalDataSettingsView()
                    } label: {
                        Label(String(localized: "settings.section.physicaldata", bundle: .gymNutshellCore), systemImage: "person.circle")
                    }
                    NavigationLink {
                        UserGoalChangeView()
                    } label: {
                        Label(String(localized: "settings.fitness.goal.edit", bundle: .gymNutshellCore), systemImage: "flame")
                    }
                    NavigationLink {
                        TrackingGoalsSettingsView()
                    } label: {
                        Label(String(localized: "settings.goals.edit", bundle: .gymNutshellCore), systemImage: "target")
                    }
                }

                // Seção de preferências do usuário.
                Section(header: Text(String(localized: "settings.section.preferences", bundle: .gymNutshellCore)).foregroundStyle(accentColor.color)) {
                    // Tema — controla os emojis de mascote e nomes de nível em todo o app.
                    NavigationLink {
                        ThemeSettingsView()
                    } label: {
                        Label(String(localized: "settings.theme.title", bundle: .gymNutshellCore), systemImage: "theatermasks")
                    }
                    // Cores — cor de destaque independente do sexo.
                    NavigationLink {
                        ColorSettingsView()
                    } label: {
                        Label(String(localized: "settings.color.title", bundle: .gymNutshellCore), systemImage: "paintpalette")
                    }
                    // Widgets — fundo personalizado pros widgets da tela inicial.
                    NavigationLink {
                        WidgetBackgroundSettingsView()
                    } label: {
                        Label(String(localized: "settings.edit.widgets", bundle: .gymNutshellCore), systemImage: "square.on.square")
                    }

                    // Sistema de medidas — abre uma página de seleção dedicada.
                    NavigationLink {
                        MeasurementSettingsView()
                    } label: {
                        Label(String(localized: "settings.preference.measurementSystem", bundle: .gymNutshellCore), systemImage: "ruler")
                    }

                    // Orientação — trava o app em retrato/paisagem/ambas.
                    // Só faz sentido no iPhone; em iPad/Mac/Vision sempre fica liberado.
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        NavigationLink {
                            OrientationSettingsView()
                        } label: {
                            Label(String(localized: "settings.preference.orientation", bundle: .gymNutshellCore), systemImage: "rotate.left")
                        }
                    }
                }

                // Seção Sistema — notificações, integrações de plataforma e backup.
                Section(header: Text(String(localized: "settings.section.system", bundle: .gymNutshellCore)).foregroundStyle(accentColor.color)) {
                    // Notificações — configuração completa das notificações locais do app.
                    NavigationLink {
                        NotificationsSettingsView()
                    } label: {
                        Label(String(localized: "settings.preference.notifications", bundle: .gymNutshellCore), systemImage: "bell.badge")
                    }

                    // Apple Health — abre uma página dedicada pra sincronização de sono e auto check-in.
                    NavigationLink {
                        HealthSettingsView()
                    } label: {
                        Label(String(localized: "settings.preference.appleHealth", bundle: .gymNutshellCore), systemImage: "heart.fill")
                    }

                    // Backup — exportação/importação via iCloud e local.
                    NavigationLink {
                        BackupSettingsView()
                    } label: {
                        Label(String(localized: "settings.backup.nav.title", bundle: .gymNutshellCore), systemImage: "externaldrive")
                    }

                    // Idioma — abre Ajustes do iOS na página do Gym Nutshell (onde aparece
                    // o seletor "Idioma preferido" gerado automaticamente pelo sistema).
                    Button {
                        if let url = NotificationManager.systemSettingsURL {
                            openURL(url)
                        }
                    } label: {
                        HStack {
                            Label(String(localized: "settings.preference.language", bundle: .gymNutshellCore), systemImage: "globe")
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                // Seção Sobre — conquista, anel de progresso e info de versão.
                Section(header: Text(String(localized: "settings.section.about", bundle: .gymNutshellCore)).foregroundStyle(accentColor.color)) {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label(String(localized: "settings.about.link", bundle: .gymNutshellCore), systemImage: "info.circle")
                    }
                    NavigationLink {
                        AppleWatchInstructionsView()
                    } label: {
                        Label(String(localized: "settings.preference.appleWatch", bundle: .gymNutshellCore), systemImage: "applewatch")
                    }
                    NavigationLink {
                        ProgressRingInfoView()
                    } label: {
                        Label(String(localized: "settings.about.progressRing", bundle: .gymNutshellCore), systemImage: "circle.dotted")
                    }
                    NavigationLink {
                        TierInfoView(theme: selectedTheme, sex: sex)
                    } label: {
                        Label(String(localized: "settings.about.achievement", bundle: .gymNutshellCore), systemImage: "trophy.fill")
                    }
                    NavigationLink {
                        StreakBonusInfoView()
                    } label: {
                        Label(String(localized: "settings.about.streakBonus", bundle: .gymNutshellCore), systemImage: "calendar.badge.checkmark")
                    }
                }

            }
            .navigationTitle(String(localized: "settings.header.title", bundle: .gymNutshellCore))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showNotificationHistory = true
                    } label: {
                        Image(systemName: "bell")
                    }
                }
            }
            .sheet(isPresented: $showNotificationHistory) {
                NotificationHistorySheet()
            }
            .navigationDestination(isPresented: $showBackup) {
                BackupSettingsView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .gaSettingsShowBackup)) { _ in
                showBackup = true
            }
            .onAppear {
                // TabView monta SettingsView lazy — se o deep-link chegou enquanto a view
                // ainda não existia, lê a flag persistente e empurra agora.
                if UserDefaults.standard.string(forKey: "pendingSettingsRoute") == "backup" {
                    UserDefaults.standard.removeObject(forKey: "pendingSettingsRoute")
                    // Pequeno delay pra garantir que a sidebar já foi renderizada antes do push.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showBackup = true
                    }
                }
            }
        } detail: {
            // NavigationStack garante sub-navegação no detail column (iPad) e back button correto (iPhone).
            NavigationStack {
                ContentUnavailableView(
                    String(localized: "settings.detail.placeholder", bundle: .gymNutshellCore),
                    systemImage: "sidebar.left"
                )
                // Sem isso o detail vazio aparece com fundo branco no light mode (iPad
                // / iPhone landscape) destoando das outras páginas que usam grouped.
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .scrollContentBackground(.hidden)
            }
        }
        // Cor de destaque aplicada no nível do NavigationSplitView pra garantir
        // que os ícones sejam coloridos tanto no iPhone quanto no iPad.
        .tint(accentColor.color)
        // Cor de fundo igual ao systemGroupedBackground — corrige barra de status branca no iPad (light mode).
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        // Sobrescreve o size class horizontal pra forçar o split no iPhone landscape (≥700 pt).
        // Em portrait o size class nativo (.compact) é mantido — NavigationSplitView colapsa normalmente.
        .environment(\.horizontalSizeClass, geo.size.width >= 700 ? .regular : .compact)
        } // GeometryReader
    }
}

// MARK: - Apple Watch instructions page

/// Página com passos manuais pra instalar o app no Apple Watch — usada porque
/// a Apple não expõe URL scheme público pra abrir o app companion Watch.
private struct AppleWatchInstructionsView: View {
    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color {
        (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color
    }

    var body: some View {
        List {
            // Ícone do app — redondo, no padrão watchOS.
            Section {
                HStack {
                    Spacer()
                    appIcon
                    Spacer()
                }
                .padding(.top, 12)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 6, trailing: 16))
            }

            Section {
                Text(String(localized: "appleWatch.sheet.intro", bundle: .gymNutshellCore))
                    .font(.body)
            }
            .listRowBackground(Color.clear)

            Section {
                step(number: 1, text: String(localized: "appleWatch.sheet.step1", bundle: .gymNutshellCore))
                step(number: 2, text: String(localized: "appleWatch.sheet.step2", bundle: .gymNutshellCore))
                step(number: 3, text: String(localized: "appleWatch.sheet.step3", bundle: .gymNutshellCore))
            } footer: {
                Text(String(localized: "appleWatch.sheet.note", bundle: .gymNutshellCore))
            }
        }
        .navigationTitle(String(localized: "appleWatch.sheet.title", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Ícone do app clipado em círculo — espelha o estilo da face do app no watchOS.
    private var appIcon: some View {
        let size: CGFloat = 80
        return Image("AboutIcon")
            .resizable()
            .interpolation(.high)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }

    @ViewBuilder
    private func step(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.body.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(accentColor))
            Text(text)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}
