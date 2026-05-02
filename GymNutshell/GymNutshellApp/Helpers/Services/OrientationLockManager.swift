// ⌘
//  GymNutshell/GymNutshellApp/Helpers/Services/OrientationLockManager.swift
//
//  Propósito: Singleton que mantém a preferência atual de orientação e aplica
//             a mudança imediatamente na cena ativa via UIWindowScene.requestGeometryUpdate.
//             O AppDelegate consulta `current.supportedInterfaceOrientations` no callback
//             `application(_:supportedInterfaceOrientationsFor:)` pra que o UIKit
//             nunca permita uma orientação fora do que o usuário escolheu.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-25.
// ⌘

import UIKit
internal import Combine

final class OrientationLockManager: ObservableObject {

    static let shared = OrientationLockManager()

    @Published private(set) var current: AppOrientation

    private init() {
        if let raw = UserDefaults.standard.string(forKey: AppOrientation.storageKey),
           let parsed = AppOrientation(rawValue: raw) {
            current = parsed
        } else {
            current = AppOrientation.systemDefault
        }
    }

    /// Aplica imediatamente a nova preferência: persiste, atualiza state e força
    /// o sistema a reavaliar a orientação suportada na cena ativa.
    func set(_ orientation: AppOrientation) {
        guard orientation != current else { return }
        current = orientation
        UserDefaults.standard.set(orientation.rawValue, forKey: AppOrientation.storageKey)
        applyToActiveScene()
    }

    private func applyToActiveScene() {
        let mask = current.supportedInterfaceOrientations
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        let prefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: mask)
        scene.requestGeometryUpdate(prefs) { _ in }
        // Força a hierarquia de UIViewController a reavaliar `supportedInterfaceOrientations`
        // — sem isso, o app pode continuar mostrando a orientação anterior até a próxima rotação.
        scene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}
