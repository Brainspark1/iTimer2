import SwiftUI
import AVFoundation

struct PomoPopoutView: View {
    var body: some View {
        Text("Pomodoro Timer")
            .font(.system(size: 35))
            .padding()
    }
}

struct PomodoroView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var audioPlayer: AVAudioPlayer?
    @Binding var showPomodoro: Bool
    @AppStorage("workDuration") private var workDuration: String = "25" // Stored in minutes
    @AppStorage("breakDuration") private var breakDuration: String = "5"  // Stored in minutes
    @State private var timeRemaining: Int = 1500 // Default to 25 minutes in seconds
    @State private var timerRunning = false
    @State private var onBreak = false
    @State private var timer: Timer? = nil

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
                .keyboardShortcut("p", modifiers: [.command,.shift])
                .padding()
            }
            
            Text(onBreak ? "Break" : "Work")
                .font(.title)
                .padding()
            
            Text("\(timeString(time: timeRemaining))")
                .font(.largeTitle)
                .padding()
                .onTapGesture {
                    openPomTimer()
                }
            
            HStack {
                Button(action: {
                    if self.timerRunning {
                        self.stopTimer()
                    } else {
                        self.startTimer()
                    }
                }) {
                    Text(self.timerRunning ? "Pause" : "Start")
                }
                .keyboardShortcut(.return, modifiers: .command)
                
                Button(action: {
                    self.resetTimer()
                }) {
                    Text("Reset")
                }
                .keyboardShortcut(.return, modifiers: [.command, .shift])
            }
            .padding()
        }
        .onAppear {
            self.timeRemaining = getWorkDuration() * 60
            self.appDelegate.isPomodoroRunning = true
            self.appDelegate.timerManager.remainingTime = self.timeRemaining
            self.appDelegate.timerManager.isBreakTime = self.onBreak
        }
    }

    func startTimer() {
        self.timerRunning = true
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.appDelegate.timerManager.remainingTime = self.timeRemaining
            } else {
                playSound()
                self.switchMode()
            }
        }
    }
    
    func stopTimer() {
        self.timerRunning = false
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func resetTimer() {
        self.stopTimer()
        self.onBreak = false
        self.timeRemaining = getWorkDuration() * 60 // Reset to work time
        self.appDelegate.timerManager.remainingTime = self.timeRemaining
        self.appDelegate.timerManager.isBreakTime = self.onBreak
    }
    
    func switchMode() {
        self.onBreak.toggle()
        self.timeRemaining = self.onBreak ? getBreakDuration() * 60 : getWorkDuration() * 60
        self.appDelegate.timerManager.remainingTime = self.timeRemaining
        self.appDelegate.timerManager.isBreakTime = self.onBreak
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
        newWindow.contentView = NSHostingView(rootView: PomoPopoutView())
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
    }
    
    func playSound() {
        guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
    
    private func getWorkDuration() -> Int {
        return Int(workDuration) ?? 25
    }
    
    private func getBreakDuration() -> Int {
        return Int(breakDuration) ?? 5
    }
}
