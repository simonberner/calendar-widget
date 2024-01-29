//
//  AppIntents.swift
//  SwiftCalendar
//
//  Created by Simon Berner on 26.01.2024.
//

import Foundation
import AppIntents

struct ToggleStudyIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Studies"
    
    func perform() async throws -> some IntentResult {
        print("Toggle Study")
        return .result()
    }
}
