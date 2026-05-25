// ⌘
//  GymNutshell/GymNutshellApp/Helpers/Services/GymNutshellAppDelegate.swift
//
//  Propósito: AppDelegate mínimo registrado via @UIApplicationDelegateAdaptor.
//             Existe pra entregar `application(_:supportedInterfaceOrientationsFor:)`,
//             que SwiftUI sozinho não expõe, sem isso não dá pra travar orientação
//             em runtime conforme o usuário escolher em Ajustes → Orientação.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-25.
// ⌘

import UIKit

final class GymNutshellAppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        // iPad / Mac / Vision: sempre liberado, a tela de Orientação nem aparece
        // nas Settings desses dispositivos. Só o iPhone respeita a preferência.
        if UIDevice.current.userInterfaceIdiom != .phone {
            return .all
        }
        return OrientationLockManager.shared.current.supportedInterfaceOrientations
    }
}
