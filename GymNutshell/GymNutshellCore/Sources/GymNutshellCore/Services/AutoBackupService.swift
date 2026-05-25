// ⌘
//  GymNutshellCore/Services/AutoBackupService.swift
//
//  Propósito: Backup automático diário no iCloud. iOS não permite executar código
//             exatamente à meia-noite, então a estratégia é checar no foreground:
//             se o último backup é anterior ao início do dia atual, grava um novo.
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-21.
// ⌘

import Foundation
import SwiftData

public enum AutoBackupService {

    /// Chave do @AppStorage que liga/desliga o backup automático.
    public static let enabledKey = "backup.icloud.autoEnabled"

    /// Roda o backup automático se todas as condições estiverem atendidas.
    /// Seguro chamar várias vezes por sessão, vira no-op depois do primeiro sucesso do dia.
    @MainActor
    public static func performIfNeeded(modelContext: ModelContext) async {
        guard UserDefaults.standard.bool(forKey: enabledKey) else { return }
        guard ICloudBackupManager.isSignedIn else { return }

        let startOfToday = Calendar.current.startOfDay(for: Date())
        if let last = await ICloudBackupManager.lastBackupDate(), last >= startOfToday {
            return
        }

        let descriptor = FetchDescriptor<DailyRecord>(sortBy: [SortDescriptor(\.date)])
        guard let records = try? modelContext.fetch(descriptor) else { return }

        do {
            let data = try BackupManager.export(records: records)
            try await ICloudBackupManager.save(data)
            NotificationManager.shared.fireBackupCompleted()
        } catch {
            // Falha silenciosa, o próximo foreground tenta de novo.
        }
    }
}
