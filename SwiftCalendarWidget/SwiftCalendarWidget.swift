//
//  SwiftCalendarWidget.swift
//  SwiftCalendarWidget
//
//  Created by Simon Berner on 21.12.22.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData

struct Provider: IntentTimelineProvider {

    let viewContext = PersistenceController.shared.container.viewContext
    var daysFetchRequest: NSFetchRequest<Day> {
        // Crate a GET request to the shared core data container (very similar to @FetchRequest)
        let request = Day.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Day.date, ascending: true)]
        request.predicate = NSPredicate(format: "date BETWEEN {%@, %@}",
                                        Date().startDateOfCalendarWithPrefixDays as CVarArg,
                                        Date().endOfMonth as CVarArg)
        return request
    }

    // Placeholder for the Widget Gallery
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), days: [], configuration: ConfigurationIntent())
    }

    // Provides the timeline entry that represents the current time and state of a widget.
    // (A widget is not a living view, it is just a snapshot of a moment in time)
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        // Call the request on the PersistenceController viewContext
        do {
            let days = try viewContext.fetch(daysFetchRequest)
            let entry = CalendarEntry(date: Date(), days: days, configuration: configuration)
            completion(entry)
        } catch {
            print("Widget failed to fetch days!")
        }
    }

    // Provides an array of timeline entries for the current time and, optionally any future times to update a widget.
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        // Call the request on the PersistenceController viewContext
        do {
            let days = try viewContext.fetch(daysFetchRequest)
            let entry = CalendarEntry(date: Date(), days: days, configuration: configuration)
            let timeline = Timeline(entries: [entry], policy: .after(.now.endOfDay))
            completion(timeline)
        } catch {
            print("Widget failed to fetch days!")
        }

    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let days: [Day]
    let configuration: ConfigurationIntent
}

struct SwiftCalendarWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: CalendarEntry

    var body: some View {
        switch family {
            case .systemMedium:
                MediumCalendarView(entry: entry, streakValue: calculateStreakDays())
            case .accessoryCircular:
                LockScreenCircularView(entry: entry)
                    .widgetURL(URL(string: "calendar"))
            case .accessoryRectangular:
                LockScreenRectangularView(entry: entry)
                    .widgetURL(URL(string: "calendar"))
            case .accessoryInline:
                Label("Streak - \(calculateStreakDays())", systemImage: "swift")
                    .widgetURL(URL(string: "streak"))
            case .systemSmall, .systemLarge, .systemExtraLarge: // don't supported here
                EmptyView()
            @unknown default:
                EmptyView()
        }
    }

    // TODO: Refactor this out
    private func calculateStreakDays() -> Int {
        guard !entry.days.isEmpty else { return 0 }

        // Only consider already past days of the month from today
        let nonFutureDays = entry.days.filter { $0.date!.dayInt <= Date().dayInt }

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

struct SwiftCalendarWidget: Widget {
    let kind: String = "SwiftCalendarWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SwiftCalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Swift Study Calendar")
        .description("Track days you study in a row with streaks.")
        .supportedFamilies([.systemMedium,
                            .accessoryCircular,
                            .accessoryRectangular,
                            .accessoryInline])
    }
}

struct SwiftCalendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        SwiftCalendarWidgetEntryView(entry: CalendarEntry(date: Date(), days: [], configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}

// MARK: - UI Components for widget class

private struct MediumCalendarView: View {
    var entry: CalendarEntry
    var streakValue: Int
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        HStack {
            // Deep linking from the Widget to the StreakView
            Link(destination: URL(string: "streak")!) {
                VStack {
                    Text("\(streakValue)")
                        .font(.system(size: 70, design: .rounded))
                        .bold()
                        .foregroundColor(.orange)
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            // Deep linking from the Widget to the CalendarView
            Link(destination: URL(string: "calendar")!) {
                VStack {
                    CalendarHeaderView(font: .caption)

                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(entry.days) { day in
                            // if it is a prefix day (past month)
                            if day.date!.monthInt != Date().monthInt {
                                Text(day.date!.formatted(.dateTime.day()))
                                    .font(.caption2)
                                    .fontWeight(.light)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(day.date!.formatted(.dateTime.day()))
                                    .font(.caption2)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(day.didStudy ? .orange : .secondary)
                                    .background(
                                        Circle()
                                            .foregroundColor(.orange.opacity(day.didStudy ? 0.3 : 0.0))
                                            .scaleEffect(1.4)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.leading, 4)
        }
        .padding()
    }
}

// Circular Lock Screen Widget View
// Shows the total study days of the current month
@available(iOS 16.1, *) // only available for iOS 16.1+
private struct LockScreenCircularView: View {
    var entry: CalendarEntry
    var currentCalendarDays: Int {
        entry.days.filter { $0.date?.monthInt == Date().monthInt }.count
    }

    var daysStudied: Int {
        entry.days.filter { $0.date?.monthInt == Date().monthInt }
            .filter { $0.didStudy }.count
    }

    var body: some View {
        Gauge(value: 15.0, in: 1...Double(currentCalendarDays)) {
//            Image(systemName: "swift")
        } currentValueLabel: {
            Text("\(daysStudied)")
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("\(currentCalendarDays)")
        }
        .gaugeStyle(.accessoryCircular)

    }
}

// Rectangular Lock Screen Widget View
private struct LockScreenRectangularView: View {
    var entry: CalendarEntry
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(entry.days) { day in
                // if it is a prefix day (past month)
                if day.date!.monthInt != Date().monthInt {
//                    Text(" ")
                    Text(day.date!.formatted(.dateTime.day()))
                        .font(.system(size: 6))
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                } else {
                    if day.didStudy {
                        Image(systemName: "swift")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 6, height: 6)
                    } else {
                        Text(day.date!.formatted(.dateTime.day()))
                            .font(.system(size: 6))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
    }
}
