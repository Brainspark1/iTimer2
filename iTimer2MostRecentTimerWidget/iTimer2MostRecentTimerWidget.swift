import WidgetKit
import SwiftUI
import Foundation

// MARK: - Entry
struct MostRecentEntry: TimelineEntry {
    let date: Date
    let item: HistoryItem?
}

// MARK: - Provider
struct MostRecentProvider: TimelineProvider {
    func placeholder(in context: Context) -> MostRecentEntry {
        MostRecentEntry(date: Date(), item: HistoryItem(name: "Focus", hours: 0, minutes: 25, seconds: 0))
    }

    func getSnapshot(in context: Context, completion: @escaping (MostRecentEntry) -> Void) {
        let latest = loadLatestHistoryItem()
        completion(MostRecentEntry(date: Date(), item: latest))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MostRecentEntry>) -> Void) {
        let latest = loadLatestHistoryItem()
        let entry = MostRecentEntry(date: Date(), item: latest)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
        completion(timeline)
    }

    private func loadLatestHistoryItem() -> HistoryItem? {
        let defaults = UserDefaults(suiteName: "group.com.nihaalg.iTimer2")
        guard let data = defaults?.data(forKey: "timerHistory") else { return nil }
        do {
            let decoded = try JSONDecoder().decode([HistoryItem].self, from: data)
            return decoded.last
        } catch {
            print("Failed to decode history for MostRecentTimerWidget: \(error)")
            return nil
        }
    }
}

// MARK: - View
struct MostRecentWidgetEntryView: View {
    let entry: MostRecentEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
//        if family == .systemMedium {
            HStack {
                Image("Green Clock Icon 1")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(.bottom, 4)
                
                Spacer()
            }
//        }
        
        VStack(alignment: .leading) {
            Text("Latest Timer")
                .font(.headline)
            if let item = entry.item {
                Text(item.timestampDescription)
                    .font(family == .systemSmall ? .caption : .body)
                    .lineLimit(2)
            } else {
                Text("No timer history found.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
            Spacer()
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(red: 40/255, green: 41/255, blue: 46/255)
        }
    }
}

// MARK: - Widget
struct MostRecentTimerWidget: Widget {
    let kind: String = "MostRecentTimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MostRecentProvider()) { entry in
            MostRecentWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Latest Timer")
        .description("Shows the information of your most recent timer.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
