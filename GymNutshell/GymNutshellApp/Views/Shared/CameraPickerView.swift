// ⌘
//  GymNutshell/GymNutshellApp/Views/Shared/CameraPickerView.swift
//
//  Propósito: Envelopa o UIImagePickerController pra que a câmera possa ser exibida
//             a partir de views SwiftUI. Requer NSCameraUsageDescription no Info.plist.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-14.
// ⌘

import SwiftUI
import UIKit

/// Apresenta a câmera do dispositivo e retorna a imagem capturada via callback.
/// Deve ser exibida como sheet. Requer NSCameraUsageDescription no Info.plist do projeto.
struct CameraPickerView: UIViewControllerRepresentable {

    // MARK: - Configuração

    /// Chamado com a imagem selecionada, ou nil se o usuário cancelou.
    let onCapture: (UIImage?) -> Void

    // MARK: - Coordenador

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            parent.onCapture(image)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCapture(nil)
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: - UIViewControllerRepresentable (protocolo de ponte SwiftUI ↔ UIKit)

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
