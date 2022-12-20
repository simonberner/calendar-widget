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
            TabView {
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                StreakView()
                    .tabItem {
                        Label("Streak", systemImage: "star")
                    }
            }
            // injection at the root level of the app
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
