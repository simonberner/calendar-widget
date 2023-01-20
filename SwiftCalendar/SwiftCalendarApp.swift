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

    @State private var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(0)
                StreakView()
                    .tabItem {
                        Label("Streak", systemImage: "star")
                    }
                    .tag(1)
            }
            // injection at the root level of the app
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            // A handler who is listing for incoming urls (here from the touch action of the Widget)
            .onOpenURL { url in
                print("Deep-link url is: \(url.absoluteString)")
                selectedTab = url.absoluteString == "calendar" ? 0 : 1
            }
        }
    }
}
