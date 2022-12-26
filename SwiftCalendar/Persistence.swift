//
//  Persistence.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 13.12.22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let databaseName = "SwiftCalendar.sqlite"


    /// Old App CoreData container
    var oldStoreURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(databaseName, conformingTo: .database)
    }

//    var oldStoreURL: URL {
//        .applicationSupportDirectory.appending(component: databaseName)
//    }

    /// Shared CoreData container
    var sharedStoreURL: URL {
        // Force unwrap the url because no one is probably going to delete the AppGroup
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dev.simonberner.SwiftCalendar")!
        return container.appendingPathComponent(databaseName, conformingTo: .database)
    }

    // Dummy data for the preview
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
//        let startDate = Calendar.current.veryShortWeekdaySymbols
        // Get the first day of the month
        let startDate = Calendar.current.dateInterval(of: .month, for: .now)!.start
        // Create 30 days of the current month
        for dayOffset in 0..<30 {
            let newDay = Day(context: viewContext)
            newDay.date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)
            newDay.didStudy = Bool.random()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SwiftCalendar")

        if inMemory {
            // internal core data store for the previews
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            // if the old store doesn't exists, use the shared store
        } else if !FileManager.default.fileExists(atPath: oldStoreURL.path()) {
            print("Old store doesn't exists, using shared URL.")
            // shared (App and Widget) core data container
            container.persistentStoreDescriptions.first!.url = sharedStoreURL
        }

        print("Container url: \(container.persistentStoreDescriptions.first!.url!)")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        migrateOldStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func migrateOldStore(for container: NSPersistentContainer) {
        // The container has a coordinator attached to it which we are using for the migration
        let coordinator = container.persistentStoreCoordinator

        // Check if there is a store at this url to migrate (prevents the migration from happening more than once)
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else {
            print("There is no oldStore to migrate from!")
            return
        }

        print("🎬 Start migrating the old store...")

        do {
            let _ = try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, type: .sqlite)
            print("🏁 Migration successful!")
        } catch {
            fatalError("Unable to migrate from old to shared store")
        }

        // Delete the old store
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
            print("🗑️ Old store deleted!")
        } catch {
            fatalError("Unable to delete the old store")
        }

    }
}
