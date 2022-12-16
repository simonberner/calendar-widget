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
     - Fetches all the days in the CoreData store -> PersistenceController
     - Any time the underling items gets changed (every time we tap on a calendar date, we update
     the didStudy to true), it automatically keeps the UI up to date.
     */
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        animation: .default)
    private var days: FetchedResults<Day>

    let weekDays = ["M", "D", "W", "T", "F", "S", "S"]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .font(.body)
                    }
                    
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days) { day in
                        Text(day.date!.formatted(.dateTime.day()))
                            .fontWeight(.bold)
                            .foregroundColor(day.didStudy ? .orange : .secondary)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Circle().foregroundColor(.orange.opacity(day.didStudy ? 0.3 : 0.0)))
                    }
                }
                Spacer()
            }
            .navigationTitle(Date().formatted(.dateTime.month(.wide)))
            .padding()
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
