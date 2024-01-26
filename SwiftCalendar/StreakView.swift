//
//  StreakView.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 20.12.22.
//

import SwiftUI
import SwiftData

struct StreakView: View {
    // Careful: even if the predicate compiles, it may fail at runtime! Conclusion: Test it beforehand!
    @Query(filter: #Predicate<Day> { $0.date > startDate && $0.date < endDate }, sort: \Day.date)
    var days: [Day]
    
    static var startDate: Date { .now.startDateOfCalendarWithPrefixDays }
    static var endDate: Date { .now.endOfMonth }

    @State private var streakValue = 0

    var body: some View {
        VStack {
            Text("\(streakValue)")
                .font(.system(size: 200, weight: .semibold, design: .rounded))
                .foregroundColor(streakValue > 0 ? .orange : .pink)
            Text("Current Study Streak")
                .bold()
                .font(.title2)
                .foregroundColor(.secondary)
            Text("(Rule: A streak is the number of days in a row you have studied. Here the streak only starts to count, if you've trained for at least the current or past day (from the current day).)")
                .font(.italic(.caption)())
                .foregroundColor(.secondary)
                .padding()
        }
        .offset(y: -28)
        .onAppear{
            streakValue = calculateStreakDays()
        }
    }

    // TODO: Refactor this out
    private func calculateStreakDays() -> Int {
        guard !days.isEmpty else { return 0 }

        // Only consider already past days of the month from today
        let nonFutureDays = days.filter { $0.date.dayInt <= Date().dayInt }

        var streakCount = 0

        // Reverse to get the days from today backwards for the streak
        for day in nonFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
            } else {
                // exclude today from finishing the streak,
                // because we might not have studied yet (and want to do so)
                if day.date.dayInt != Date().dayInt {
                    break
                }
            }
        }

        return streakCount
    }
}

#Preview {
    StreakView()
}
