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

    public static func load() async throws -> Data? {
        guard let folderURL = await resolveContainerURL() else {
            throw ICloudError.unavailable
        }
        let name = filename

        return try await Task.detached {
            let fileURL = folderURL.appendingPathComponent(name)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return nil as Data?
            }
            return try Data(contentsOf: fileURL)
        }.value
    }

    // MARK: - Metadados

    public static func lastBackupDate() async -> Date? {
        guard let folderURL = await resolveContainerURL() else { return nil }
        let name = filename

        return await Task.detached {
            let fileURL = folderURL.appendingPathComponent(name)
            guard FileManager.default.fileExists(atPath: fileURL.path),
                  let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                  let date = attrs[.modificationDate] as? Date
            else { return nil as Date? }
            return date
        }.value
    }

    // MARK: - Erros

    public enum ICloudError: LocalizedError {
        case unavailable

        public var errorDescription: String? {
            switch self {
            case .unavailable:
                return String(localized: "settings.backup.icloud.error.unavailable", bundle: .module)
            }
        }
    }
}
