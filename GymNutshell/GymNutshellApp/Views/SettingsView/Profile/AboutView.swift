// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Profile/AboutView.swift
//
//  Propósito: Exibe a versão do app e as informações de contato do desenvolvedor.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-12.
// ⌘

import SwiftUI
import GymNutshellCore

/// Mostra as informações básicas do app: versão, número de build e link pra enviar feedback.
struct AboutView: View {

    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color { (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color }

    @State private var showTipJar: Bool = false

    // MARK: - Body

    var body: some View {
        List {

            // Seção de identidade do app — ícone real, nome e string de versão.
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        appIcon
                        Text("Gym Nutshell")
                            .font(.title2.bold())
                        Text("\(String(localized: "settings.about.version", bundle: .gymNutshellCore)) \(appVersion)")
                            .font(.subheadline)
                            .foregroundStyle(accentColor)
                    }
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, 0)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 6, trailing: 16))
            }

            // Descrição do app — texto centralizado explicando o conceito.
            Section {
                Text(String(localized: "settings.about.description", bundle: .gymNutshellCore))
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
            }

            // Crédito do desenvolvedor com links de contato.
            // Feedback primeiro, depois site.
            Section(String(localized: "settings.about.developer.header", bundle: .gymNutshellCore)) {
                Link(destination: URL(string: "mailto:jonathasmrt@me.com")!) {
                    Label(String(localized: "settings.about.feedback", bundle: .gymNutshellCore),
                          systemImage: "envelope")
                        .foregroundStyle(accentColor)
                }
                Link(destination: URL(string: "https://jonathasmotta.com")!) {
                    Label(String(localized: "settings.about.website", bundle: .gymNutshellCore),
                          systemImage: "globe")
                        .foregroundStyle(accentColor)
                }
            }

            // Apoie o desenvolvedor — abre o Tip Jar (IAP consumível).
            Section(String(localized: "settings.about.support.header", bundle: .gymNutshellCore)) {
                Button {
                    showTipJar = true
                } label: {
                    Label(String(localized: "settings.about.support.button", bundle: .gymNutshellCore),
                          systemImage: "heart.fill")
                        .foregroundStyle(accentColor)
                }
            }
        }
        .listSectionSpacing(.compact)
        .sheet(isPresented: $showTipJar) {
            TipJarView()
        }
        // Limita a largura da lista no iPad e paisagem.
        .navigationTitle(String(localized: "settings.about.title", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Ícone do app

    private var appIcon: some View {
        let size: CGFloat = 80
        return Image("AboutIcon")
            .resizable()
            .interpolation(.high)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }

    // MARK: - Helpers de versão

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
}
