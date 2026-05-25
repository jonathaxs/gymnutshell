// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Preferences/WidgetBackgroundSettingsView.swift
//
//  Propósito: Permite escolher entre 3 modos de fundo pros widgets da tela inicial:
//             Padrão (segue iOS), Destaque (cor de destaque do app) e Personalizada
//             (ColorPicker). A escolha é feita via Picker segmentado e o footer
//             muda explicando o que cada modo faz.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-05-12.
// ⌘

import SwiftUI
import WidgetKit
import GymNutshellCore

struct WidgetBackgroundSettingsView: View {

    // Modo selecionado, armazenado no App Group pro widget extension ler.
    @AppStorage(WidgetBackgroundStore.modeKey,
                store: UserDefaults(suiteName: "group.com.jonathaxs.gymnutshell"))
    private var mode: WidgetBackgroundMode = .accent

    // Cor de destaque atual, usada pelo preview quando mode == .accent.
    @AppStorage(AppAccentColor.storageKey) private var storedAccentRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color {
        (AppAccentColor(rawValue: storedAccentRaw) ?? .blue).color
    }

    @State private var pickedColor: Color = .blue

    private static let defaultPickedColor: Color = Color(red: 0.0, green: 0.478, blue: 1.0)

    var body: some View {
        Form {
            Section {
                Picker(String(localized: "widgetBackground.mode.label", bundle: .gymNutshellCore), selection: $mode) {
                    Text(String(localized: "widgetBackground.mode.system", bundle: .gymNutshellCore)).tag(WidgetBackgroundMode.system)
                    Text(String(localized: "widgetBackground.mode.accent", bundle: .gymNutshellCore)).tag(WidgetBackgroundMode.accent)
                    Text(String(localized: "widgetBackground.mode.custom", bundle: .gymNutshellCore)).tag(WidgetBackgroundMode.custom)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            } footer: {
                Text(footerText(for: mode))
            }

            if mode == .custom {
                Section {
                    ColorPicker(
                        String(localized: "widgetBackground.picker", bundle: .gymNutshellCore),
                        selection: $pickedColor,
                        supportsOpacity: false
                    )
                }
            }

            if mode != .system {
                Section(String(localized: "widgetBackground.preview", bundle: .gymNutshellCore)) {
                    HStack(spacing: 16) {
                        previewTile(size: 90)
                        previewTile(size: 90, wide: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    // Previews puramente visuais, ocultos do VoiceOver pra evitar
                    // ruído ("imagem, imagem" enquanto o usuário ajusta as opções).
                    .accessibilityHidden(true)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(String(localized: "widgetBackground.title", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let saved = WidgetBackgroundStore.loadCustomColor() {
                pickedColor = saved.color
            } else {
                pickedColor = Self.defaultPickedColor
            }
        }
        .onChange(of: pickedColor) { _, newColor in
            persist(color: newColor)
        }
        .onChange(of: mode) { _, newMode in
            // Ao entrar no modo Personalizada pela primeira vez, garante que há cor
            // persistida pro widget renderizar mesmo antes do usuário tocar no picker.
            if newMode == .custom {
                persist(color: pickedColor)
            }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    // MARK: - Footer dinâmico

    private func footerText(for mode: WidgetBackgroundMode) -> String {
        switch mode {
        case .system:
            return String(localized: "widgetBackground.footer.system", bundle: .gymNutshellCore)
        case .accent:
            return String(localized: "widgetBackground.footer.accent", bundle: .gymNutshellCore)
        case .custom:
            return String(localized: "widgetBackground.footer.custom", bundle: .gymNutshellCore)
        }
    }

    // MARK: - Preview tile

    @ViewBuilder
    private func previewTile(size: CGFloat, wide: Bool = false) -> some View {
        let width: CGFloat = wide ? size * 2.1 : size
        let sourceColor: Color = mode == .accent ? accentColor : pickedColor
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(WidgetBackground.gradient(from: sourceColor))
            .frame(width: width, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
    }

    // MARK: - Persistência

    private func persist(color: Color) {
        let bg = backgroundModel(for: color)
        WidgetBackgroundStore.saveCustomColor(bg)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func backgroundModel(for color: Color) -> WidgetBackground {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return WidgetBackground(
            red: Double(r),
            green: Double(g),
            blue: Double(b),
            alpha: Double(a)
        )
    }
}
