
import Foundation
import SwiftUI

struct StopwatchView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var provm: ProViewModel
    @EnvironmentObject var timerViewModel: TimerViewModel
    @Binding var showStopwatch: Bool
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                Text("Stopwatch")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                Button(action: {
                    self.showStopwatch = false
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                    Text("Exit")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
                .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut("2", modifiers: [.command, .shift]))
            }
            
            Text(timeString(time: timerManager.stopwatchTimeElapsed))
                .font(.system(size: 40))
                .padding()

            HStack {
                Button(action: {
                    if timerManager.stopwatchIsRunning {
                        self.pauseStopwatch()
                    } else {
                        self.startStopwatch()
                    }
                }) {
                    Text(timerManager.stopwatchIsRunning ? "Pause" : "Start")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .frame(width: 112, height: 26)
                .padding()
                .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut(.return, modifiers: .command))

                Button(action: {
                    self.resetStopwatch()
                }) {
                    Text("Reset")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .frame(width: 112, height: 26)
                .padding()
                .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut(.return, modifiers: [.command, .shift]))
            }
            
            Spacer()

        }
        .padding(.bottom, 20)
        .onAppear() {
            self.appDelegate.isStopwatchRunning = true
            print("stopwatch true")
        }
    }

    func startStopwatch() {
        timerManager.stopwatchIsRunning = true
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            timerManager.stopwatchTimeElapsed += 0.01
        }
    }

    func pauseStopwatch() {
        timerManager.stopwatchIsRunning = false
        self.timer?.invalidate()
        self.timer = nil
    }

    func resetStopwatch() {
        timerManager.stopwatchIsRunning = false
        self.timer?.invalidate()
        self.timer = nil
        timerManager.stopwatchTimeElapsed = 0
    }

    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time * 100).truncatingRemainder(dividingBy: 100))
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
