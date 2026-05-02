// ⌘
//  GymNutshell/GymNutshellApp/Models/AppOrientation.swift
//
//  Propósito: Preferência do usuário sobre travamento de orientação. O app pode
//             ficar travado em retrato, em paisagem (esquerda ou direita) ou
//             aceitar todas as orientações suportadas pelo dispositivo.
//             Persistido em UserDefaults; consumido pelo AppDelegate via
//             `OrientationLockManager.shared.current.supportedInterfaceOrientations`.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-25.
// ⌘

import Foundation
import UIKit

/// Modo de travamento de orientação escolhido pelo usuário.
enum AppOrientation: String, CaseIterable, Identifiable {
    case portrait
    case landscape
    case both

    var id: String { rawValue }

    static let storageKey = "app.orientation.lock"

    /// Máscara de orientações que o AppDelegate retornará pro UIKit. No modo
    /// `.both`, respeita o que o dispositivo aceita (iPhone não suporta upside down).
    var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch self {
        case .portrait:  return .portrait
        case .landscape: return [.landscapeLeft, .landscapeRight]
        case .both:
            if UIDevice.current.userInterfaceIdiom == .pad
                || ProcessInfo.processInfo.isiOSAppOnMac
                || ProcessInfo.processInfo.isMacCatalystApp {
                return .all
            }
            return [.portrait, .landscapeLeft, .landscapeRight]
        }
    }

    /// Default por dispositivo: iPhone trava em retrato; iPad / macOS / Vision aceitam ambas.
    static var systemDefault: AppOrientation {
        if UIDevice.current.userInterfaceIdiom == .pad
            || ProcessInfo.processInfo.isiOSAppOnMac
            || ProcessInfo.processInfo.isMacCatalystApp {
            return .both
        }
        return .portrait
    }
}
