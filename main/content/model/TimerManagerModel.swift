//
//  TimerManagerModel.swift
//  iTimer2
//
//  Created by Nihaal Garud on 17/08/2024.
//

import SwiftUI
import Combine
import Foundation
import UserNotifications

class TimerManager: ObservableObject {
    var timer: AnyCancellable?
    @Published var isRunning: Bool = false
    @Published var remainingTime: Int = 0
    @Published var isBreakTime: Bool = false
    @Published var isPomodoroRunning: Bool = false
    @Published var timeName: String = ""
    @Published var history: [HistoryItem] = []
    @Published var hoursInput: String = ""
    @Published var minutesInput: String = ""
    @Published var secondsInput: String = ""
    @Published var progress: Double = 0.0 // Added progress property
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = true
    @AppStorage("notificationsEnabled") var notificationsEnabled = true
    
    // Stopwatch
    @Published var stopwatchTimeElapsed: TimeInterval = 0
    @Published var stopwatchIsRunning: Bool = false
    
    let un = UNUserNotificationCenter.current()

    // Updated HistoryItem to conform to Codable
    struct HistoryItem: Identifiable, Codable {
        let id: UUID
        let name: String
        let hours: Int
        let minutes: Int
        let seconds: Int
        let timestamp: Date
        
        // Custom initializer to assign UUID automatically
        init(id: UUID = UUID(), name: String, hours: Int, minutes: Int, seconds: Int, timestamp: Date = Date()) {
            self.id = id
            self.name = name
            self.hours = hours
            self.minutes = minutes
            self.seconds = seconds
            self.timestamp = timestamp
        }
        
        var description: String {
            return "\(name): \(hours)h \(minutes)m \(seconds)s"
        }
        
        var timestampDescription: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            return "\(name): \(hours)h \(minutes)m \(seconds)s - \(dateFormatter.string(from: timestamp))"
        }
    }

    // File URL for persisting history
    private var historyFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("timerHistory.json")
    }

    // Initialize and load history
    init() {
        loadHistory()
    }

    // MARK: - Persistence Methods

    // Load history from JSON file
    func loadHistory() {
        do {
            let data = try Data(contentsOf: historyFileURL)
            let decodedHistory = try JSONDecoder().decode([HistoryItem].self, from: data)
            DispatchQueue.main.async {
                self.history = decodedHistory
            }
            print("History loaded successfully.")
        } catch {
            print("Failed to load history: \(error.localizedDescription)")
            self.history = [] // Initialize with empty array if loading fails
        }
    }

    // Save history to JSON file
    func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: historyFileURL, options: [.atomicWrite, .completeFileProtection])
            print("History saved successfully.")
        } catch {
            print("Failed to save history: \(error.localizedDescription)")
        }
    }

    // MARK: - Timer Methods

    func resetTimerState() {
        timer?.cancel()
        isRunning = false
        remainingTime = 0
        isBreakTime = false
        timeName = ""
        progress = 0.0 // Reset progress
    }

    func startNewTimer(hours: Int, minutes: Int, seconds: Int, name: String) {
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        if totalSeconds > 0 {
            remainingTime = totalSeconds
            timeName = name
            isRunning = true
            progress = 0.0 // Initialize progress
            timer?.cancel()

            let newItem = HistoryItem(name: name, hours: hours, minutes: minutes, seconds: seconds, timestamp: Date())
            history.append(newItem)  // Add to history
            saveHistory() // Persist the change

            timer = Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .sink { _ in
                    DispatchQueue.main.async {
                        if self.remainingTime > 0 {
                            self.remainingTime -= 1
                            self.progress = Double(totalSeconds - self.remainingTime) / Double(totalSeconds) // Update progress
                        } else {
                            self.stopTimer()
                            self.timer?.cancel()
                            self.isRunning = false
                            self.progress = 1.0 // Ensure progress is fully completed when timer ends
                        }
                    }
                }
        }
    }
    
    func stopTimer() {
        remainingTime = 0
        timer?.cancel()
        isRunning = false
        if notificationsEnabled {
            self.sendNotification()
            print("Notification sent")
        }
    }
    
    func sendNotification() {
        un.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                
                content.title = "Timer Ended"
                content.subtitle = "Your iTimer2 Timer has finished running"
                content.sound = UNNotificationSound.default
                
                let id = UUID().uuidString
                let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
                self.un.add(request) { (error) in
                    if let error = error {
                        print("Failed to schedule notification: \(error.localizedDescription)")
                    } else {
                        print("Notification scheduled successfully.")
                    }
                }
                
            }
        }
    }

    func clearHistory() {
        history.removeAll()
        saveHistory() // Persist the change
    }
}
