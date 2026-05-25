// ⌘
//  GymNutshellCore/Services/ICloudBackupManager.swift
//
//  Propósito: Salva e carrega o backup JSON do app no iCloud Drive.
//             Usa o container Documents do iCloud (iCloud.com.jonathaxs.GymNutshell).
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-03-29.
// ⌘

import Foundation

// MARK: - ICloudBackupManager

/// Lida com a leitura e escrita do arquivo de backup do Gym Nutshell no iCloud Drive.
/// Todos os métodos são async pra não travar a thread principal.
public enum ICloudBackupManager {

    private static let filename = "GymNutshell-Backup.json"
    private static let containerID = "iCloud.com.jonathaxs.GymNutshell"

    // MARK: - Disponibilidade

    public static var isSignedIn: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    private static func resolveContainerURL() async -> URL? {
        await Task.detached {
            FileManager.default.url(forUbiquityContainerIdentifier: containerID)?
                .appendingPathComponent("Documents")
        }.value
    }

    // MARK: - Salvar

    public static func save(_ data: Data) async throws {
        guard let folderURL = await resolveContainerURL() else {
            throw ICloudError.unavailable
        }
        let name = filename

        try await Task.detached {
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }
            let fileURL = folderURL.appendingPathComponent(name)
            try data.write(to: fileURL, options: .atomic)
        }.value
    }

    // MARK: - Carregar

    /// URL do placeholder gerado pelo iOS quando o arquivo está no iCloud mas ainda
    /// não foi baixado pro device: mesma pasta, nome com ponto na frente e sufixo `.icloud`.
    private static func placeholderURL(for fileURL: URL) -> URL {
        fileURL.deletingLastPathComponent()
            .appendingPathComponent("." + fileURL.lastPathComponent + ".icloud")
    }

    public static func load() async throws -> Data? {
        guard let folderURL = await resolveContainerURL() else {
            throw ICloudError.unavailable
        }
        let name = filename

        return try await Task.detached {
            let fileURL = folderURL.appendingPathComponent(name)
            let fm = FileManager.default

            if !fm.fileExists(atPath: fileURL.path) {
                // Pode existir como placeholder (.icloud), tentar disparar download.
                let placeholder = placeholderURL(for: fileURL)
                guard fm.fileExists(atPath: placeholder.path) else {
                    return nil as Data?
                }
                try fm.startDownloadingUbiquitousItem(at: fileURL)

                // Poll curto até o arquivo materializar (até ~10s).
                let deadline = Date().addingTimeInterval(10)
                while !fm.fileExists(atPath: fileURL.path) {
                    if Date() >= deadline {
                        throw ICloudError.downloadTimeout
                    }
                    try await Task.sleep(nanoseconds: 250_000_000)
                }
            }

            return try Data(contentsOf: fileURL)
        }.value
    }

    // MARK: - Metadados

    public static func lastBackupDate() async -> Date? {
        guard let folderURL = await resolveContainerURL() else { return nil }
        let name = filename

        return await Task.detached {
            let fm = FileManager.default
            let fileURL = folderURL.appendingPathComponent(name)

            // Caminho normal: arquivo já baixado, modificationDate disponível.
            if fm.fileExists(atPath: fileURL.path),
               let attrs = try? fm.attributesOfItem(atPath: fileURL.path),
               let date = attrs[.modificationDate] as? Date {
                return date
            }

            // Fallback: arquivo só existe como placeholder iCloud, ainda assim
            // queremos exibir uma data pro footer ("último backup em ...").
            let placeholder = placeholderURL(for: fileURL)
            if fm.fileExists(atPath: placeholder.path),
               let attrs = try? fm.attributesOfItem(atPath: placeholder.path),
               let date = attrs[.modificationDate] as? Date {
                return date
            }

            return nil as Date?
        }.value
    }

    // MARK: - Erros

    public enum ICloudError: LocalizedError {
        case unavailable
        case downloadTimeout

        public var errorDescription: String? {
            switch self {
            case .unavailable:
                return String(localized: "settings.backup.icloud.error.unavailable", bundle: .gymNutshellCore)
            case .downloadTimeout:
                return String(localized: "settings.backup.icloud.error.downloadTimeout", bundle: .gymNutshellCore)
            }
        }
    }
}
