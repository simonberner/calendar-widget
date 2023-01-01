//
//  Date+Ext.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 16.12.22.
//

import Foundation

extension Date {

    // We force unwrap here because we always have a date

    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }

    var endOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.end
    }

    var endOfDay: Date {
        Calendar.current.dateInterval(of: .day, for: self)!.end
    }

    /// Returns today past month (e.g. today 19.12.22 -> returns 19.11.22)
    var startOfPreviousMonth: Date {
        let dayInPreviousMonth = Calendar.current.date(byAdding: .month, value: -1, to: self)!
        return dayInPreviousMonth.startOfMonth
    }

    var startOfNextMonth: Date {
        let dayInNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: self)!
        return dayInNextMonth.startOfMonth
    }


    /// Total number of days of the month of that date
    var numberOfDaysInMonth: Int {
        // endOfMonth returns the 1st of next month at midnight.
        // An adjustment of -1 is necessary to get last day of current month
        let endDateAdjustment = Calendar.current.date(byAdding: .day, value: -1, to: self.endOfMonth)!
        return Calendar.current.component(.day, from: endDateAdjustment)
    }


    /// Int value of the day of that date
    var dayInt: Int {
        Calendar.current.component(.day, from: self)
    }


    /// Int value of the month of that date
    var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }


    /// Full name of the month of that date
    var monthFullName: String {
        self.formatted(.dateTime.month(.wide))
    }


    /// Prefix days to adjust if the startOfMonth day is not on a Monday
    /// (How many days do we have to go back into the past month for starting at a Monday?)
    /// (e.g Thursday 1. December22 -> Monday 28.November22 are 4days)
    var startDateOfCalendarWithPrefixDays: Date {
        // What day of the week is it the first of the month?
        // Sunday == 1, Monday == 2, ... Saturday == 7
        let startOfMonthWeekday = Calendar.current.component(.weekday, from: startOfMonth)
        // Because the days are not 0 indexed (Monday is the first day of the week)
        let numberOfPrefixDays = startOfMonthWeekday - 2
        // Start day of the past month for the calendar day (which is on a Monday)
        let startDateForCalendar = Calendar.current.date(byAdding: .day, value: -numberOfPrefixDays, to: startOfMonth)!
        return startDateForCalendar
    }
}
