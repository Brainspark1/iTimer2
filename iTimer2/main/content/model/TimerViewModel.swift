// Shared View Model for Timer
import Foundation
import SwiftUI
import AVFoundation
import UserNotifications

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int = 1500 // Default to 25 minutes in seconds
    @Published var isOnBreak: Bool = false
    @Published var isTimerRunning: Bool = false

    let un = UNUserNotificationCenter.current()

    private var timer: Timer? = nil
    var workDuration: Int = 25 // Default work duration
    var breakDuration: Int = 5  // Default break duration

    var onModeSwitch: ((Bool, TimeInterval) -> Void)? // Callback for mode switch with previous mode and duration
    
    func setWorkDuration(_ duration: Int) {
            self.workDuration = duration
        }
        
        func setBreakDuration(_ duration: Int) {
            self.breakDuration = duration
        }

    func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.playSound()
                self.switchMode()
                self.sendSwitchNotification()
            }
        }
    }

    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer(workDuration: Int) {
        stopTimer()
        isOnBreak = false
        timeRemaining = workDuration * 60 // Reset to work time
    }
    
    func sendSwitchNotification() {
        un.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                
                content.title = "Time to Switch!"
                content.subtitle = "Your previous Pomodoro mode section has finished"
                content.sound = UNNotificationSound.default
                
                let id = UUID().uuidString
                let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
                self.un.add(request) { (error) in
                    if let error = error {
                        print("Failed to schedule switch notification: \(error.localizedDescription)")
                    } else {
                        print("Switch notification scheduled successfully.")
                    }
                }
                
            }
        }
    }

    func switchMode() {
        let previousMode = isOnBreak
        let duration = Double(getWorkDuration() * 60 - timeRemaining) // Calculate actual time spent in previous mode
        isOnBreak.toggle()
        timeRemaining = isOnBreak ? getBreakDuration() * 60 : getWorkDuration() * 60
        onModeSwitch?(previousMode, duration)
    }

    func getWorkDuration() -> Int {
        return 25 // Default work duration
    }

    func getBreakDuration() -> Int {
        return 5 // Default break duration
    }

    private func playSound() {
        guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            print("Sound file not found")
            return
        }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}
