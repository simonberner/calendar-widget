//
//  Day.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 14.01.2024.
//
//

import Foundation
import SwiftData

// We don't need optionals in SwiftData
@Model class Day {
    var date: Date
    var didStudy: Bool
    
    init(date: Date, didStudy: Bool) {
        self.date = date
        self.didStudy = didStudy
    }
    
}
