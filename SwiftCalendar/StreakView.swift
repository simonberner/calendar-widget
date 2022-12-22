//
//  StreakView.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 20.12.22.
//

import SwiftUI

struct StreakView: View {

    // We only consider the days of the current month for calculating the streak days
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        predicate: NSPredicate(format: "(date >= %@) AND (date <= %@)",
                               Date().startOfMonth as CVarArg,
                               Date().endOfMonth as CVarArg))
    private var days: FetchedResults<Day>

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

    private func calculateStreakDays() -> Int {
        guard !days.isEmpty else { return 0 }

        // Only consider already past days of the month from today
        let nonFutureDays = days.filter { $0.date!.dayInt <= Date().dayInt }

        var streakCount = 0

        // Reverse to get the days from today backwards for the streak
        for day in nonFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
            } else {
                // exclude today from finishing the streak,
                // because we might not have studied yet (and want to do so)
                if day.date?.dayInt != Date().dayInt {
                    break
                }
            }
        }

        return streakCount
    }
}

struct StreakView_Previews: PreviewProvider {
    static var previews: some View {
        StreakView()
    }
}
