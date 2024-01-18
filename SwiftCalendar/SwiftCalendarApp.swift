//
//  SwiftCalendarApp.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 13.12.22.
//

import SwiftUI
import SwiftData

@main
struct SwiftCalendarApp: App {
    @State private var selectedTab = 0
    
    static var sharedStoreURL: URL {
        // Force unwrap the url because no one is probably going to delete the AppGroup
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dev.simonberner.SwiftCalendar")!
        return container.appendingPathComponent("SwiftCal.sqlite")
    }
    
    let container: ModelContainer = {
        let config = ModelConfiguration(url: sharedStoreURL)
        return try! ModelContainer(for: Day.self, configurations: config)
    }()
    
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
            .modelContainer(container) // injecting the model container so that every view can access it
            // A handler who is listing for incoming urls (here from the touch action of the Widget)
            .onOpenURL { url in
                print("Deep-link url is: \(url.absoluteString)")
                selectedTab = url.absoluteString == "calendar" ? 0 : 1
            }
        }
    }
}
