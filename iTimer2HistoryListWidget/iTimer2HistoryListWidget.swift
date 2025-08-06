import WidgetKit
import SwiftUI
import Foundation

struct HistoryEntry: TimelineEntry, Equatable {
    let date: Date
    let history: [HistoryItem]
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HistoryEntry {
        let sampleItem = HistoryItem(name: "Focus", hours: 0, minutes: 25, seconds: 0)
        return HistoryEntry(date: Date(), history: [sampleItem])
    }

    func getSnapshot(in context: Context, completion: @escaping (HistoryEntry) -> ()) {
        let entry = HistoryEntry(date: Date(), history: loadHistory())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HistoryEntry>) -> ()) {
        let entries = [HistoryEntry(date: Date(), history: loadHistory())]

        // Update timeline every 1 minute to pick up new history data
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!

        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }

    // Load history data from shared UserDefaults (app group)
    func loadHistory() -> [HistoryItem] {
        let defaults = UserDefaults(suiteName: "group.com.nihaalg.iTimer2")
        guard let data = defaults?.data(forKey: "timerHistory") else {
            print("Widget: No data found for key timerHistory")
            return []
        }

        do {
            let decoded = try JSONDecoder().decode([HistoryItem].self, from: data)
            return decoded
        } catch {
            print("Widget failed to decode history: \(error)")
            return []
        }
    }
}

// MARK: - Widget View
struct iTimer2HistoryWidgetEntryView: View {
    var entry: HistoryEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        
        HStack {
            
            VStack(alignment: .leading, spacing: 6) {
                
                if family == .systemLarge {
                    HStack {
                        Image("Green Clock Icon 1")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(.bottom)
                        
                        Spacer()
                    }
                }
                
                Text("Past Timer History")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 4)

                    if entry.history.isEmpty {
                        Text("No timer history found")
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(entry.history.prefix(family == .systemLarge ? 6 : 3)) { item in
                            Text(item.timestampDescription)
                                .font(.caption.monospacedDigit())
                                .lineLimit(1)
                        }
                    }
                
                Spacer()
                Spacer()
                Spacer()
            }
            .padding()
            
            Spacer()
            Spacer()
        }
        .containerBackground(for: .widget) {
            Color(red: 40/255, green: 41/255, blue: 46/255)
        }
    }
}

// MARK: - Widget Configuration
struct iTimer2HistoryWidget: Widget {
    let kind: String = "iTimer2HistoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            iTimer2HistoryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Timer History")
        .description("Displays your past timer history.")
        .supportedFamilies([.systemMedium, .systemLarge]) // Only medium and large sizes
    }
}
