//
//  Persistence.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 26.01.2024.
//

import Foundation
import SwiftData

struct Persistence {
    static var container: ModelContainer {
        let container: ModelContainer = {
            let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dev.simonberner.SwiftCalendar")!
                .appendingPathComponent("SwiftCal.sqlite")
            let config = ModelConfiguration(url: sharedStoreURL)
            return try! ModelContainer(for: Day.self, configurations: config)
        }()
        return container
    }
}
