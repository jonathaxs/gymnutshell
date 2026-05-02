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
    static var gymNutshellCore: Bundle { .module }
}
