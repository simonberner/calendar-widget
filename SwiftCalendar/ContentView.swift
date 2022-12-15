//
//  ContentView.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 13.12.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // viewContext is the key to everything in CoreDate
    @Environment(\.managedObjectContext) private var viewContext

    /*
     Property wrapper:
     - Fetches all the days in the CoreData store
     - Any time the underling items gets changed (every time we tap on a calendar date, we update
     the didStudy to true), it automatically keeps the UI up to date.
     */
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        animation: .default)
    private var days: FetchedResults<Day>

    var body: some View {
        NavigationView {
            List {
                ForEach(days) { day in
                    Text(day.date!.formatted())
                }
            }
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
