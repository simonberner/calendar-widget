//
//  ContentView.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 13.12.22.
//

import SwiftUI
import SwiftData
import WidgetKit

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    // Careful: Predicate compile but may fail at runtime! Conclusion: TEST IT!
    @Query(filter: #Predicate<Day> { $0.date > startDate && $0.date < endDate }, sort: \Day.date)
    var days: [Day]
    
    static var startDate: Date { .now.startDateOfCalendarWithPrefixDays }
    static var endDate: Date { .now.endOfMonth }

    var body: some View {
        NavigationView {
            VStack {
                CalendarHeaderView()

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days) { day in
                        // if it is a prefix day (from the past month)
                        if day.date.monthInt != Date().monthInt {
                            Text(day.date.formatted(.dateTime.day()))
                                .fontWeight(.light)
                                .foregroundColor(.secondary)
                        } else {
                            Text(day.date.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundColor(day.didStudy ? .orange : .secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(Circle().foregroundColor(.orange.opacity(day.didStudy ? 0.3 : 0.0)))
                                .onTapGesture {
                                    if day.date.dayInt <= Date().dayInt {
                                        day.didStudy.toggle()
                                        WidgetCenter.shared.reloadTimelines(ofKind: "SwiftCalendarWidget")
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
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: date.startOfMonth)!
            let newDay = Day(date: date, didStudy: false)
            modelContext.insert(newDay) // SwiftData autosave
        }
    }
}

#Preview {
    CalendarView()
}
