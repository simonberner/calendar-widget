//
//  CalendarHeaderView.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 26.12.22.
//

import SwiftUI

struct CalendarHeaderView: View {
    let weekDays = ["M", "D", "W", "T", "F", "S", "S"]
    var font: Font = .body

    var body: some View {
        HStack {
            ForEach(weekDays, id: \.self) { day in
                Text(day)
                    .font(font)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .font(.body)
            }
        }
    }
}

struct CalendarHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarHeaderView()
    }
}
