import Foundation
import SwiftUI
import AVFoundation

// Main View
struct PomodoroView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var provm: ProViewModel
    @StateObject private var timerViewModel = TimerViewModel()
    @State private var audioPlayer: AVAudioPlayer?
    @Binding var showPomodoro: Bool
    @AppStorage("workDuration") private var workDuration: String = "25" // Stored in minutes
    @AppStorage("breakDuration") private var breakDuration: String = "5"  // Stored in minutes

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Spacer()
                Text("Pomodoro Timer")
                    .font(.largeTitle)
                    .padding()
                Spacer()
                Button(action: {
                    self.stopTimer()
                    timerManager.remainingTime = 0
                    self.showPomodoro = false
                    self.appDelegate.isPomodoroRunning = false
                    timerManager.resetTimerState()
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                    Text("Exit")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
                .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut("p", modifiers: [.command, .shift]))
            }

            Text(timerViewModel.isOnBreak ? "Break" : "Work")
                .font(.title)
                .padding()

            Text("\(timeString(time: timerViewModel.timeRemaining))")
                .font(.largeTitle)
                .padding()
                .onTapGesture {
                    openPomTimer()
                }

            HStack {
                Button(action: {
                    if timerViewModel.isTimerRunning {
                        timerViewModel.stopTimer()
                    } else {
                        timerViewModel.startTimer()
                    }
                }) {
                    Text(timerViewModel.isTimerRunning ? "Pause" : "Start")
                }
                
                Button(action: {
                    timerViewModel.resetTimer(workDuration: getWorkDuration())
                }) {
                    Text("Reset")
                }
            }
            .padding()
        }
        .onAppear {
            timerViewModel.timeRemaining = getWorkDuration() * 60
            timerViewModel.isOnBreak = false
            self.appDelegate.isPomodoroRunning = true
            self.appDelegate.timerManager.remainingTime = timerViewModel.timeRemaining
            self.appDelegate.timerManager.isBreakTime = timerViewModel.isOnBreak
        }
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func openPomTimer() {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered, defer: false)
        
        newWindow.center()
        newWindow.title = "Pomodoro Timer"
        newWindow.isReleasedWhenClosed = false
        newWindow.contentView = NSHostingView(rootView: PomoPopoutView(viewModel: timerViewModel))
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
    }

    private func getWorkDuration() -> Int {
        return Int(workDuration) ?? 25
    }

    private func getBreakDuration() -> Int {
        return Int(breakDuration) ?? 5
    }

    private func stopTimer() {
        timerViewModel.stopTimer()
    }
}
