// ⌘
//  GymNutshellCore/Models/DailyRecord.swift
//
//  Propósito: Model SwiftData que persiste um dia concluído com métricas, conquista e pontos.
//
//  Created by Jonathas Motta (@jonathaxs) on 2025-08-16.
// ⌘

import Foundation
import SwiftData

// MARK: - Modelo SwiftData

/// DailyRecord representa um único dia concluído no Gym Nutshell.
/// Cada propriedade é persistida automaticamente pelo SwiftData.
@Model
public final class DailyRecord {

    public var date: Date = Date()
    public var water: Int = 0
    public var protein: Int = 0
    @Attribute(originalName: "carb") public var carbs: Int = 0
    @Attribute(originalName: "fat") public var goodFat: Int = 0
    public var fiber: Int = 0
    public var sleep: Int = 0
    /// [String: Int] codificado em JSON que armazena a ingestão de cada meta personalizada no dia.
    public var customValues: Data = Data()
    public var didWorkout: Bool = false
    public var didCardio: Bool = false
    public var workoutRestDay: Bool = false
    public var cardioRestDay: Bool = false
    /// [String: Bool] codificado em JSON com o estado de "dia de descanso" das metas personalizadas.
    public var customRestDays: Data = Data()
    public var percent: Int = 0
    @Attribute(originalName: "catTitle") public var achievementTitle: String = ""
    @Attribute(originalName: "catEmoji") public var achievementEmoji: String = ""
    public var points: Int = 0

    // MARK: - Inicializador

    public init(
        date: Date = Date(),
        water: Int,
        protein: Int,
        carbs: Int,
        goodFat: Int,
        fiber: Int,
        sleep: Int,
        percent: Int,
        achievementTitle: String,
        achievementEmoji: String,
        points: Int
    ) {
        self.date = date
        self.water = water
        self.protein = protein
        self.carbs = carbs
        self.goodFat = goodFat
        self.fiber = fiber
        self.sleep = sleep
        self.percent = percent
        self.achievementTitle = achievementTitle
        self.achievementEmoji = achievementEmoji
        self.points = points
    }
}
