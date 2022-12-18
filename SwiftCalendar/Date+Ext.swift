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
}
