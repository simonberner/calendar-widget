//
//  SwiftCalendarApp.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 13.12.22.
//

import SwiftUI

@main
struct SwiftCalendarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            CalendarView()
                // injection at the root level of the app
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
