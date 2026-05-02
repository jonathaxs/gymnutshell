//
//  Item.swift
//  GymNutshell
//
//  Created by Jonathas Motta on 01/05/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
