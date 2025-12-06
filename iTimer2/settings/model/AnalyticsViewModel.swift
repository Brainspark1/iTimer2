//
//  AnalyticsViewModel.swift
//  iTimer2
//
//  Created by Nihaal Garud on 28/11/25.
//

import SwiftUI
import Foundation
import AppKit

class AnalyticsViewModel: ObservableObject {
    @AppStorage("enabledAnalytics") var enabledAnalytics: Bool = false
    
    struct AnalyticsEntry: Identifiable, Codable {
        let id: UUID
        let type: String // "timer", "pomodoro_work", "pomodoro_break", "stopwatch"
        let duration: TimeInterval // in seconds
        let timestamp: Date
        
        init(type: String, duration: TimeInterval, timestamp: Date = Date()) {
            self.id = UUID()
            self.type = type
            self.duration = duration
            self.timestamp = timestamp
        }
    }
    
    @Published var analyticsEntries: [AnalyticsEntry] = []
    
    private var analyticsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("analyticsEntries.json")
    }
    
    init() {
        loadAnalytics()
    }
    
    func addEntry(type: String, duration: TimeInterval, timestamp: Date = Date()) {
        let entry = AnalyticsEntry(type: type, duration: duration, timestamp: timestamp)
        analyticsEntries.append(entry)
        saveAnalytics()
    }
    
    func loadAnalytics() {
        do {
            let data = try Data(contentsOf: analyticsFileURL)
            let decodedEntries = try JSONDecoder().decode([AnalyticsEntry].self, from: data)
            DispatchQueue.main.async {
                self.analyticsEntries = decodedEntries
            }
            print("Analytics loaded successfully.")
        } catch {
            print("Failed to load analytics: \(error.localizedDescription)")
            self.analyticsEntries = []
        }
    }
    
    func saveAnalytics() {
        do {
            let data = try JSONEncoder().encode(analyticsEntries)
            try data.write(to: analyticsFileURL, options: [.atomicWrite, .completeFileProtection])
            print("Analytics saved to file")
        } catch {
            print("Failed to save analytics: \(error.localizedDescription)")
        }
    }
    
    // Computed properties for metrics
    var totalPomodoroSessions: Int {
        analyticsEntries.filter { $0.type == "pomodoro_work" }.count
    }
    
    var totalWorkMinutes: Double {
        let workEntries = analyticsEntries.filter { $0.type == "pomodoro_work" }
        return workEntries.reduce(0) { $0 + $1.duration } / 60
    }

    var totalBreakMinutes: Double {
        let breakEntries = analyticsEntries.filter { $0.type == "pomodoro_break" }
        return breakEntries.reduce(0) { $0 + $1.duration } / 60
    }
    
    func weeklyBreakdown() -> [String: [String: Double]] {
        let calendar = Calendar.current
        var weeklyData: [String: [String: Double]] = [:]
        
        for entry in analyticsEntries {
            let weekOfYear = calendar.component(.weekOfYear, from: entry.timestamp)
            let year = calendar.component(.year, from: entry.timestamp)
            let key = "\(year)-W\(weekOfYear)"
            
            if weeklyData[key] == nil {
                weeklyData[key] = ["timer": 0, "pomodoro": 0, "stopwatch": 0]
            }
            
            let minutes = entry.duration / 60
            switch entry.type {
            case "timer":
                weeklyData[key]!["timer"]! += minutes
            case "pomodoro_work", "pomodoro_break":
                weeklyData[key]!["pomodoro"]! += minutes
            case "stopwatch":
                weeklyData[key]!["stopwatch"]! += minutes
            default:
                break
            }
        }
        
        return weeklyData
    }
    
    func exportLogs() {
        let csvString = "ID,Type,Duration (seconds),Timestamp\n" + analyticsEntries.map { "\($0.id),\($0.type),\($0.duration),\($0.timestamp)" }.joined(separator: "\n")

        DispatchQueue.main.async {
            let savePanel = NSSavePanel()
            savePanel.allowedFileTypes = ["csv"]
            savePanel.nameFieldStringValue = "analytics_logs.csv"
            savePanel.title = "Export Analytics Logs"

            if savePanel.runModal() == .OK, let url = savePanel.url {
                do {
                    try csvString.write(to: url, atomically: true, encoding: .utf8)
                    print("Analytics logs exported to \(url.path)")
                } catch {
                    print("Failed to export analytics logs: \(error.localizedDescription)")
                }
            }
        }
    }
}
