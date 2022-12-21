//
//  SwiftCalendarWidgetBundle.swift
//  SwiftCalendarWidget
//
//  Created by Simon Berner on 21.12.22.
//

import WidgetKit
import SwiftUI

@main
struct SwiftCalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        SwiftCalendarWidget()
        SwiftCalendarWidgetLiveActivity()
    }
}
