// ⌘
//  GymNutshellCore/Bundle+GymNutshellCore.swift
//
//  Propósito: Expõe o resource bundle do GymNutshellCore pros app targets (iPhone, Watch),
//             pra que `String(localized: "x", bundle: .gymNutshellCore)` funcione fora do package.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-26.
// ⌘

import Foundation

public extension Bundle {
    /// Resource bundle do package GymNutshellCore.
    /// Usar em call sites de `String(localized:bundle:)` ou `NSLocalizedString(_:bundle:comment:)`
    /// fora do código do package, pros recursos (Localizable.strings) serem encontrados.
    ///
    /// No watchOS, retorna o sub-bundle `.lproj` específico do idioma escolhido no iPhone
    /// (sincronizado via WatchConnectivity em `app.preferredLanguage`). Isso é necessário
    /// porque o watchOS não tem per-app language, então não há como mudar o locale do
    /// processo em runtime — a única forma confiável é apontar `String(localized:bundle:)`
    /// pro bundle de localização correto diretamente.
    static var gymNutshellCore: Bundle {
        #if os(watchOS)
        if let lang = UserDefaults.standard.string(forKey: "app.preferredLanguage"),
           let path = Bundle.module.path(forResource: lang, ofType: "lproj"),
           let langBundle = Bundle(path: path) {
            return langBundle
        }
        #endif
        return .module
    }
}
