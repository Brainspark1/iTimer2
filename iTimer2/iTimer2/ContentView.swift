import SwiftUI
import Combine
import AVFoundation
import Foundation
import AppKit

class TimerManager: ObservableObject {
    var timer: AnyCancellable?
    @Published var isRunning: Bool = false
    @Published var remainingTime: Int = 0
    @Published var isBreakTime: Bool = false
    @Published var timeName: String = ""
    @Published var history: [HistoryItem] = []

    struct HistoryItem: Identifiable {
        let id = UUID()
        let name: String
        let hours: Int
        let minutes: Int
        let seconds: Int
        let timestamp: Date
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

    func resetTimerState() {
        timer?.cancel()
        isRunning = false
        remainingTime = 0
        isBreakTime = false
        timeName = ""
    }

    func startNewTimer(hours: Int, minutes: Int, seconds: Int, name: String) {
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        if totalSeconds > 0 {
            remainingTime = totalSeconds
            timeName = name
            isRunning = true
            timer?.cancel()

            let newItem = HistoryItem(name: name, hours: hours, minutes: minutes, seconds: seconds, timestamp: Date())
            history.append(newItem)  // Add to history

            timer = Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .sink { _ in
                    DispatchQueue.main.async {
                        if self.remainingTime > 0 {
                            self.remainingTime -= 1
                        } else {
                            self.timer?.cancel()
                            self.isRunning = false
                        }
                    }
                }
        }
    }

    func clearHistory() {
        history.removeAll()
    }
}

struct OnBoardView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        Image("Green Clock Icon")
            .resizable()
            .frame(width: 100, height: 100)
            .padding()
        Text("Welcome to iTimer2")
            .font(.title)
        
        TextCarouselView()
        
        Button("Let's Go!") {
            dismissWindow(id: "onboard")
        }
        .padding()
    }
}

struct TextCarouselView: View {
    let items = ["Time anything and everything with the in-built easy-to-use timer.", "Toggle on Pomodoro Mode to enjoy short bursts of break and work.", "Use keyboard shortcuts to help your work...and time...fly by!"]

    var body: some View {
        TabView {
            ForEach(0..<items.count, id: \.self) { index in
                TextView(text: items[index])
            }
        }
        .keyboardShortcut(.rightArrow)
    }
}

struct TextView: View {
    let text: String

    var body: some View {
        VStack {
            Text(text)
                .padding()
        }
    }
}

struct PopoutView: View {
    
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        
        Text("\(timeString(time: timerManager.remainingTime))")
            .font(.system(size: 50))
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        HStack {
            Button(action: {
                timerManager.isRunning ? pauseTimer() : contTimer()
            }) {
                Text(timerManager.isRunning ? "Pause" : "Start")
            }
            .keyboardShortcut(.return, modifiers: .command)
            .fixedSize()
            .padding()
            
            Button(action: stopTimer) {
                Text("Stop")
            }
            .keyboardShortcut(.return, modifiers: [.command, .shift])
            .fixedSize()
        }
        
    }
    
    func timeString(time: Int) -> String {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func contTimer() {
        timerManager.isRunning = true
        timerManager.timer?.cancel()
        
        timerManager.timer = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
                DispatchQueue.main.async {
                    if self.timerManager.remainingTime > 0 {
                        self.timerManager.remainingTime -= 1
                    } else {
                        self.timerManager.timer?.cancel()
                        self.timerManager.isRunning = false
                    }
                }
            }
    }
    
    func pauseTimer() {
        timerManager.timer?.cancel()
        timerManager.isRunning = false
    }
    
    func stopTimer() {
        timerManager.remainingTime = 0
        timerManager.timer?.cancel()
        timerManager.isRunning = false
    }

}

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var timerManager: TimerManager
    @State var showTimestamps: Bool = false
    var onSelect: (Int, Int, Int) -> Void

    var body: some View {
        VStack {
            Spacer()
            Text("History")
                .font(.title)
            Spacer()
            
            Text("Tap on any previous timer to start a new timer with that preset")
                .font(.title3)
            
            Toggle(isOn: $showTimestamps) {
                Text("Show Timestamps")
            }
            .padding()

            HStack {
                Button("Clear History") {
                    timerManager.clearHistory()  // Call the method to clear history
                }
                .foregroundColor(.red)
                .padding()
                .fixedSize()

                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .fixedSize()
            }
            .padding()

            List(timerManager.history) { historyItem in
                Text(showTimestamps ? historyItem.timestampDescription : historyItem.description)
                    .onTapGesture {
                        onSelect(historyItem.hours, historyItem.minutes, historyItem.seconds)
                        presentationMode.wrappedValue.dismiss()
                    }
            }

            Spacer()
        }
        .padding()
        .frame(width: 300, height: 400)
    }
}

struct ContentView: View {
    @State private var hoursInput: String = ""
    @State private var minutesInput: String = ""
    @State private var secondsInput: String = ""
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var transToggle: TransToggle
    @State private var audioPlayer: AVAudioPlayer?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showPomodoro = false
    @State private var initialTimeSet = false
    @State private var showHistory = false
    @State private var showCaffeinate = false
    @State private var workTime: Int = 1500 // 25 minutes
    @State private var breakTime: Int = 300 // 5 minutes
    @State private var timeRemaining: Int = 1500
    @State private var isOnBreak: Bool = false
    @State private var fontSize: CGFloat = 40.0
    
    var body: some View {
        
        VStack {
            if !showPomodoro {
                HStack {
                        Image("Green Clock Icon")
                            .resizable()
                            .frame(width: 25, height: 25)
                    
                    Spacer()
                    
                    Button(action: {
                        openNewWindow(title: "Preferences")
                    }) {
                        Text("Preferences")
                            .foregroundColor(.gray)
                    }
                    .fixedSize()
                    .keyboardShortcut(",", modifiers: .command)
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: quitApp) {
                        Text("Quit")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                    .keyboardShortcut("q", modifiers: .command)
                }
            }
            
            if showPomodoro {
                PomodoroView(showPomodoro: $showPomodoro)
                    .environmentObject(timerManager)
                    .frame(width: 350, height: 325)
            } else {
                Text("\(timeString(time: timerManager.remainingTime))")
                    .font(.system(size: fontSize))
                    .padding()
                    .onTapGesture {
                        openPopoutTimer()
                    }
                
                HStack {
                    TextField("Hours", text: $hoursInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .fixedSize()
                    
                    TextField("Minutes", text: $minutesInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .fixedSize()
                    
                    TextField("Seconds", text: $secondsInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .fixedSize()
                    
                    Button(action: {
                        timerManager.isRunning ? pauseTimer() : startTimer()
                    }) {
                        Text(timerManager.isRunning ? "Pause" : "Start")
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                    .fixedSize()
                    
                    Button(action: stopTimer) {
                        Text("Stop")
                    }
                    .keyboardShortcut(.return, modifiers: [.command, .shift])
                    .fixedSize()
                }
                
                Divider()
                
                HStack {
                    TextField("Name", text: $timerManager.timeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        self.showPomodoro.toggle()
                    }) {
                        Text("Pomodoro Mode")
                            .foregroundColor(.red)
                    }
                    .keyboardShortcut("p", modifiers: .command)
                    .fixedSize()
                    
                    Button(action: {
                        self.showHistory.toggle()
                    }) {
                        Text("History")
                    }
                    .padding()
                    .fixedSize()
                    .keyboardShortcut("y", modifiers: .command)
                    
                    CaffeinateModeView()
                }
                .sheet(isPresented: $showHistory) {
                    HistoryView { hours, minutes, seconds in
                        hoursInput = String(hours)
                        minutesInput = String(minutes)
                        secondsInput = String(seconds)
                    }
                    .environmentObject(timerManager)
                }
                
            }
        }
        .padding()
        .onAppear {
            timerManager.$remainingTime
                .sink { remainingTime in
                    if remainingTime == 0 && timerManager.isRunning {
                        playSound()
                        timerManager.isRunning = false
                    }
                }
                .store(in: &cancellables)
        }
        .overlay(
            Button(action: openPopoutTimer) {
                EmptyView()
            }
                .keyboardShortcut("=", modifiers: .command)
                .opacity(0)
        )
    }
    
    func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "Unknown"
    }
    
    func startTimer() {
        if !initialTimeSet {
            let hours = Int(hoursInput) ?? 0
            let minutes = Int(minutesInput) ?? 0
            let seconds = Int(secondsInput) ?? 0
            
            timerManager.startNewTimer(hours: hours, minutes: minutes, seconds: seconds, name: timerManager.timeName)
            initialTimeSet = true
        } else {
            timerManager.isRunning = true
            timerManager.timer?.cancel()
            
            timerManager.timer = Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .sink { _ in
                    DispatchQueue.main.async {
                        if self.timerManager.remainingTime > 0 {
                            self.timerManager.remainingTime -= 1
                        } else {
                            self.timerManager.timer?.cancel()
                            self.timerManager.isRunning = false
                            self.initialTimeSet = false
                        }
                    }
                }
        }
    }
    
    func pauseTimer() {
        timerManager.timer?.cancel()
        timerManager.isRunning = false
    }
    
    func stopTimer() {
        timerManager.remainingTime = 0
        timerManager.timer?.cancel()
        timerManager.isRunning = false
        initialTimeSet = false
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
    
    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    func timeString(time: Int) -> String {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func openPopoutTimer() {
        let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable, .resizable, .miniaturizable],
                backing: .buffered, defer: false)
            
            newWindow.center()
            newWindow.title = "Popout Timer"
            newWindow.isReleasedWhenClosed = false
        newWindow.contentView = NSHostingView(rootView: PopoutView().environmentObject(timerManager))
            newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
    }

    func openNewWindow(title: String) {
        // Create a new window
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 425),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        // Center the window
        newWindow.center()
        newWindow.title = title
        newWindow.isReleasedWhenClosed = false
        
        // Make the window's background semi-transparent
        newWindow.isOpaque = false
        newWindow.backgroundColor = NSColor.clear
        
        // Create a visual effect view for blurring
        let visualEffectView = NSVisualEffectView(frame: newWindow.contentView!.bounds)
        visualEffectView.autoresizingMask = [.width, .height]
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .popover // Adjust material to your needs
        visualEffectView.state = .active

        // Add the visual effect view to the window's content view
        newWindow.contentView?.addSubview(visualEffectView, positioned: .below, relativeTo: nil)
        
        // Set up the content view
        let contentView = NSHostingView(rootView: PreferencesView(fontSize: $fontSize))
        contentView.frame = newWindow.contentView!.bounds
        contentView.autoresizingMask = [.width, .height]
        
        // Ensure the content view is fully visible
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor // Ensure the content view's background is also transparent

        // Add the content view on top of the visual effect view
        newWindow.contentView?.addSubview(contentView, positioned: .above, relativeTo: visualEffectView)
        
        // Show the window
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TimerManager())
            .environmentObject(TransToggle())
            .frame(width: 400, height: 300)
    }
}
