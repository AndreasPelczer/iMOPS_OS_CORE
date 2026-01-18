//
//  Item.swift
//  iMOPS_OS_CORE
//
//  Created by Andreas Pelczer on 18.01.26.
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
