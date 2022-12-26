//
//  ContentView.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 13.12.22.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    // viewContext is the key to everything in CoreDate
    @Environment(\.managedObjectContext) private var viewContext

    /*
     Property wrapper:
     - Fetches all the days in the CoreData store -> PersistenceController
     - Any time the underling items gets changed (every time we tap on a calendar date, we update
     the didStudy to true), it automatically keeps the UI up to date.
     - Predicate: only give us days in a certain date range (start of the month
     with prefix days from the past month to the end of the current month)
     */
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        predicate: NSPredicate(format: "(date >= %@) AND (date <= %@)",
                               Date().startDateOfCalendarWithPrefixDays as CVarArg,
                               Date().endOfMonth as CVarArg))
    private var days: FetchedResults<Day>

    var body: some View {
        NavigationView {
            VStack {
                CalendarHeaderView()

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days) { day in
                        // if it is a prefix day (past month)
                        if day.date!.monthInt != Date().monthInt {
                            Text("\(day.date!.formatted(.dateTime.day()))")
                                .fontWeight(.light)
                                .foregroundColor(.secondary)
                        } else {
                            Text(day.date!.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundColor(day.didStudy ? .orange : .secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(Circle().foregroundColor(.orange.opacity(day.didStudy ? 0.3 : 0.0)))
                                .onTapGesture {
                                    if day.date!.dayInt <= Date().dayInt {
                                        day.didStudy.toggle()
                                        // Save in the CoreData store
                                        do {
                                            try viewContext.save()
                                            print("✅ \(day.date!.dayInt) now studied!")
                                        } catch {
                                            print("❌ saving viewContext failed!")
                                        }
                                    } else {
                                        print("❌ Can't study in the future!")
                                    }
                                }
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle(Date().formatted(.dateTime.month(.wide)))
            .padding()
            .onAppear {
                // if FetchRequest returns nothing (from the persistence store),
                // we have to create the days first
                if days.isEmpty {
                    createMonthDays(for: .now.startOfPreviousMonth)
                    createMonthDays(for: .now)
                    // case for when we role over a month and all we have
                    // in the store are the prefix days
                } else if days.count < 7 { // do we only have the prefix days in our data store?
                    createMonthDays(for: .now)
                }
            }
        }
    }


    /// Create all the days of a month and save them in the viewContext
    /// of CoreData.
    /// - Parameter date: The date to create the days of the month from
    func createMonthDays(for date: Date) {
        for dayOffset in 0..<date.numberOfDaysInMonth {
            let newDay = Day(context: viewContext)
            newDay.date = Calendar.current.date(byAdding: .day, value: dayOffset, to: date.startOfMonth)
            newDay.didStudy = false
        }

        do {
            try viewContext.save()
            print("✅ \(date.monthFullName) days created!")
        } catch {
            print("❌ saving viewContext failed!")

        }

    }

    struct CalendarView_Previews: PreviewProvider {
        static var previews: some View {
            CalendarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
