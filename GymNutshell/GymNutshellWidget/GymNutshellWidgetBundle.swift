// ⌘
//  GymNutshellWidget/GymNutshellWidgetBundle.swift
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-29.
// ⌘

import WidgetKit
import SwiftUI

@main
struct GymNutshellWidgetBundle: WidgetBundle {
    var body: some Widget {
        GymNutshellWidget()
        GymNutshellWidgetControl()
        GymNutshellWidgetLiveActivity()
    }
}
