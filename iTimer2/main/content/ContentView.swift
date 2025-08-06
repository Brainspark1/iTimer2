import SwiftUI
import Combine
import AVFoundation
import Foundation
import AppKit
import KeyboardShortcuts
import UserNotifications
import ApplicationServices

struct ContentView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var transToggle: TransToggle
    @EnvironmentObject var provm: ProViewModel
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var soundModel: SoundModel
    @EnvironmentObject private var layoutvm: LayoutViewModel
    @State private var audioPlayer: AVAudioPlayer?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showPomodoro = false
    @State private var showStopwatch = false
    @State private var initialTimeSet = false
    @State private var showHistory = false
    @State private var showCaffeinate = false
    @State private var workTime: Int = 1500 // 25 minutes
    @State private var breakTime: Int = 300 // 5 minutes
    @State private var timeRemaining: Int = 1500
    @State private var isOnBreak: Bool = false
    @State private var fontSize: CGFloat = 48.0
    @State private var showPresets = false
    @StateObject private var presetManager = PresetManager()
    @State private var showManageSheet = false
    let un = UNUserNotificationCenter.current()
    
    var body: some View {
        
        VStack {
//            if !showPomodoro && !showStopwatch {
//
//                    if timerManager.hasCompletedOnboarding == true {
//                                
//                                Button(action: {
//                                    openOnboarding()
//                                }) {
//                                    
//                                    Text("Get the most from iTimer2")
//                                }
//                                .padding(.top, 35)
//                            } else if provm.proTrue == false && timerManager.hasCompletedOnboarding == false {
//                                
//                                Button(action: {
//                                    openProPreferences()
//                                }) {
//                                    Text("Want to upgrade?")
//                                }
//                                .padding(.top, 35)
//                            }
//                    }

                    if showPomodoro {
                        PomodoroView(showPomodoro: $showPomodoro)
                            .environmentObject(timerManager)
                    } else if showStopwatch {
                        StopwatchView(showStopwatch: $showStopwatch)
                            .environmentObject(timerManager)
                            .environmentObject(AppDelegate())
                            .environmentObject(ProViewModel())
                            .environmentObject(TimerViewModel())
                    } else {
                        
                        if timerManager.hasCompletedOnboarding == true {
                            Button(action: {
                                openOnboarding()
                            }) {
                                Text("Get the most from iTimer2")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                    .fixedSize()
                                    .buttonStyle(PlainButtonStyle())
                                    .padding([.top, .bottom], 40)
                        } else {
                            Text("\(timeString(time: timerManager.remainingTime))")
                                .font(.system(size: fontSize))
                                .padding()
                                .padding(.top, 20)
                                .onTapGesture {
                                    openPopoutTimer()
                                }
                        }
                    }

                    if !showPomodoro && !showStopwatch {

                    HStack {
                        Spacer()
                        TextField("Hours", text: $timerManager.hoursInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 92, height: 26)
                        Spacer()
                        TextField("Minutes", text: $timerManager.minutesInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 92, height: 26)
                        Spacer()
                        TextField("Seconds", text: $timerManager.secondsInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 92, height: 26)
                        Spacer()
                    }
                    .padding(.bottom, 9)

                    Divider()
                        .frame(width: 436)

                    TextField("Name", text: $timerManager.timeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.top, .bottom], 8)
                        .frame(width: 295)
                    
                    Divider()
                        .frame(width: 436)

                    HStack {
                        Spacer()
                        Button(action: {
                            if timerManager.isRunning {
                                pauseTimer()
                            } else {
                                startMainTimer()
                            }
                        }) {
                            Text(timerManager.isRunning ? "Pause" : "Start")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                                .fixedSize()
                                .buttonStyle(PlainButtonStyle())
                                .frame(width: 112, height: 26)
                                .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut(.return, modifiers: .command))
                                .contextMenu {
                                    if provm.proTrue {
                                        Group {
                                            Button("1 minute") { startWithPreset(hours: 0, minutes: 1, seconds: 0) }
                                            Button("2 minutes") { startWithPreset(hours: 0, minutes: 2, seconds: 0) }
                                            Button("5 minutes") { startWithPreset(hours: 0, minutes: 5, seconds: 0) }
                                            Button("10 minutes") { startWithPreset(hours: 0, minutes: 10, seconds: 0) }
                                            Button("15 minutes") { startWithPreset(hours: 0, minutes: 15, seconds: 0) }
                                            Button("30 minutes") { startWithPreset(hours: 0, minutes: 30, seconds: 0) }
                                            Button("1 hour") { startWithPreset(hours: 1, minutes: 0, seconds: 0) }
                                        }

                                        Divider()

                                        ForEach(presetManager.presets) { preset in
                                            Button(preset.title) {
                                                startWithPreset(hours: preset.hours, minutes: preset.minutes, seconds: preset.seconds)
                                            }
                                        }

                                        Divider()

                                        Button("Manage Presets…") {
                                            showManageSheet = true
                                        }
                                    } else {
                                        Text("Upgrade to iTimer2 Pro for timer presets")
                                    }
                                }
                                .sheet(isPresented: $showManageSheet) {
                                    ManagePresetsSheet(manager: presetManager)
                                }
                                Spacer()
                                Button(action: stopTimer) {
                                    Text("Stop")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .fixedSize()
                                .buttonStyle(PlainButtonStyle())
                                .frame(width: 112, height: 26)
                                .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut(.return, modifiers: [.command, .shift]))
                                Spacer()
                    }
                    .padding([.top, .bottom], 8)

                    Divider()
                        .frame(width: 436)

                    HStack {
                        Spacer()
                        Spacer()
                        Button(action: {
                            self.showPomodoro.toggle()
                        }) {
                            Text("Pomodoro")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut("1", modifiers: .command))
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 102, height: 26)
                        .padding(.trailing, 3)
                        Spacer()
                        Button(action: {
                            self.showStopwatch.toggle()
                        }) {
                            Text("Stopwatch")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut("2", modifiers: .command))
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 102, height: 26)
                        .fixedSize()
                        Spacer()
                        Button(action: {
                            self.showHistory.toggle()
                        }) {
                            Text("History")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut("y", modifiers: .command))
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 102, height: 26)
                        Spacer()
                    }
                    .padding([.top, .bottom], 8)
                    .padding(.horizontal, 25)
                    .sheet(isPresented: $showHistory) {
                        HistoryView { hours, minutes, seconds in
                            timerManager.hoursInput = String(hours)
                            timerManager.minutesInput = String(minutes)
                            timerManager.secondsInput = String(seconds)
                        }
                        .environmentObject(timerManager)
                        .environmentObject(ProViewModel())
                    }

                    Divider()
                        .frame(width: 436)

                    HStack {
                        Button(action: {
                                    openPreferences()
                                }) {
                                    Text("Preferences")
                                }
                                .buttonStyle(PlainButtonStyle())
                                .opacity(0.7)
                                .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut(",", modifiers: .command))
                                Spacer()
                            .padding(.horizontal, 85)
                                Button(action: quitApp) {
                                    Text("Quit")
                                }
                                .buttonStyle(PlainButtonStyle())
                                .opacity(0.7)
                                .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut("q", modifiers: .command))
                        }
                    .padding(.bottom, 32)

                    Spacer()

                    }

                }
//                .frame(width: 255, height: (timerManager.hasCompletedOnboarding == false || !provm.proTrue) ? 342 : 290)
                .frame(width: 255, height: 300)
                .padding([.leading, .trailing, .top], 36)
                .padding(.bottom, 14)
                .onAppear {
                    setupKeyboardShortcuts()
                }
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
                        .opacity(0)
                        .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut("=", modifiers: .command))
                )
    }
    
    private func setupKeyboardShortcuts() {
            if provm.proTrue {
                
                print("Setting up keyboard shortcuts because provm.proTrue is true")
                // Set up keyboard shortcuts when provm.proTrue is true
                KeyboardShortcuts.onKeyUp(for: .startTimer) {
                    print("Start Timer Shortcut Triggered")
                    if showPomodoro {
                        viewModel.isTimerRunning ? viewModel.stopTimer() : viewModel.startTimer()
                    } else {
                        timerManager.isRunning ? pauseTimer() : startMainTimer()
                    }
                }

                KeyboardShortcuts.onKeyUp(for: .stopTimer) {
                    print("Stop Timer Shortcut Triggered")
                    stopTimer()
                }

                KeyboardShortcuts.onKeyUp(for: .openPom) {
                    print("Pom Shortcut Triggered")
                    showPomodoro = true
                }

                KeyboardShortcuts.onKeyUp(for: .closePom) {
                    print("No pom Shortcut Triggered")
                    showPomodoro = false
                    timerManager.remainingTime = 0
                }
                
                KeyboardShortcuts.onKeyUp(for: .openStopwatch) {
                    print("Open stopwatch shortcut triggered")
                    showStopwatch = true
                }
                
                KeyboardShortcuts.onKeyUp(for: .closeStopwatch) {
                    print("close stopwatch shortcut triggered")
                    showStopwatch = false
                }

                KeyboardShortcuts.onKeyUp(for: .popoutTimer) {
                    print("Popout Shortcut Triggered")
                    openPopoutTimer()
                }

                KeyboardShortcuts.onKeyUp(for: .history) {
                    print("show history Shortcut Triggered")
                    showHistory = true
                }

                KeyboardShortcuts.onKeyUp(for: .preferences) {
                    print("preferences Shortcut Triggered")
                    openPreferences()
                }

                KeyboardShortcuts.onKeyUp(for: .quit) {
                    print("quit Shortcut Triggered")
                    quitApp()
                }
                
//                KeyboardShortcuts.onKeyUp(for: .onlyTimer) {
//                    print("Only timer shortcut triggered")
//                    layoutvm.onlyTimerMode.toggle()
//                }
            }
        }
    
    func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "Unknown"
    }
    
    func startMainTimer() {
        // Ensure the timer starts fresh by stopping any existing timer

        if !initialTimeSet {
            let hours = Int(timerManager.hoursInput) ?? 0
            let minutes = Int(timerManager.minutesInput) ?? 0
            let seconds = Int(timerManager.secondsInput) ?? 0

            timerManager.startNewTimer(hours: hours, minutes: minutes, seconds: seconds, name: timerManager.timeName)
            initialTimeSet = true
        }

        timerManager.isRunning = true
        timerManager.timer?.cancel() // Cancel any existing timer to avoid conflicts

        timerManager.timer = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
                DispatchQueue.main.async {
                    print("Timer tick - Remaining Time: \(self.timerManager.remainingTime)")

                    if self.timerManager.remainingTime > 0 {
                        self.timerManager.remainingTime -= 1
                    } else {
                        // Call stopTimer() when remaining time reaches zero
                        self.stopTimer()
                        print("Timer reached zero")
                    }
                }
            }
    }
    
    func startWithPreset(hours: Int, minutes: Int, seconds: Int) {
            timerManager.hoursInput = String(hours)
            timerManager.minutesInput = String(minutes)
            timerManager.secondsInput = String(seconds)
            startMainTimer() // Start the timer after setting the preset
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
        playSound()
        if timerManager.notificationsEnabled {
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
    
    func playSound() {
        guard let soundURL = Bundle.main.url(forResource: soundModel.selectedSound, withExtension: "wav") else {
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
        newWindow.contentView = NSHostingView(rootView: PopoutView().environmentObject(timerManager).environmentObject(ProViewModel()))
            newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
    }
    
    func openOnboarding() {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 500),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered, defer: false)
        let onboardIdentifier = NSUserInterfaceItemIdentifier("onboarding")
        
        newWindow.center()
        newWindow.title = "Onboarding Screen"
        newWindow.identifier = onboardIdentifier
        newWindow.isReleasedWhenClosed = false
        
        let onboardingView = NewOnboardingView(onFinish: {
            newWindow.close()  // Close the window when onboarding is finished
        })
        .frame(width: 750, height: 425)
        
        newWindow.contentView = NSHostingView(rootView: onboardingView.environmentObject(timerManager).environmentObject(ProViewModel()))
        newWindow.standardWindowButton(.closeButton)?.isHidden = true
        newWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
        newWindow.standardWindowButton(.zoomButton)?.isHidden = true
        
        //hide title and bar
        newWindow.titleVisibility = .hidden
        newWindow.titlebarAppearsTransparent = true
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
    }

    func openPreferences() {
        // Create a new window
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 750, height: 425),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        // Center the window
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        
        // Make the window's background semi-transparent
        newWindow.isOpaque = false
        newWindow.backgroundColor = NSColor.clear
        
        // Create a visual effect view for blurring
        let visualEffectView = NSVisualEffectView(frame: newWindow.contentView!.bounds)
        visualEffectView.autoresizingMask = [.width, .height]
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .popover
        visualEffectView.state = .active

        newWindow.contentView?.addSubview(visualEffectView, positioned: .below, relativeTo: nil)
        
        // Set up the content view
        let contentView = NSHostingView(rootView: ListPreferencesView(fontSize: $fontSize).environmentObject(ProViewModel()).environmentObject(SoundModel()).environmentObject(LayoutViewModel()).environmentObject(PreferencesViewModel()))
        contentView.frame = newWindow.contentView!.bounds
        contentView.autoresizingMask = [.width, .height]
        
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor
        newWindow.contentView?.addSubview(contentView, positioned: .above, relativeTo: visualEffectView)

        // Show the window
        if let miniaturizeButton = newWindow.standardWindowButton(.miniaturizeButton) {
                miniaturizeButton.isEnabled = false
                miniaturizeButton.isTransparent = false
                miniaturizeButton.alphaValue = 0.5 // Make it look inactive
            }
            
        if let zoomButton = newWindow.standardWindowButton(.zoomButton) {
            zoomButton.isEnabled = false
            zoomButton.isTransparent = false
            zoomButton.alphaValue = 0.5 // Make it look inactive
        }
    
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        newWindow.orderFrontRegardless()
    }
    
    func openProPreferences() {
        // Create a new window
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 750, height: 425),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        // Center the window
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        
        // Make the window's background semi-transparent
        newWindow.isOpaque = false
        newWindow.backgroundColor = NSColor.clear
        
        // Create a visual effect view for blurring
        let visualEffectView = NSVisualEffectView(frame: newWindow.contentView!.bounds)
        visualEffectView.autoresizingMask = [.width, .height]
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .popover
        visualEffectView.state = .active

        newWindow.contentView?.addSubview(visualEffectView, positioned: .below, relativeTo: nil)
        
        // Set up the content view
        let contentView = NSHostingView(rootView: ListProPreferencesView(fontSize: $fontSize).environmentObject(ProViewModel()).environmentObject(SoundModel()).environmentObject(LayoutViewModel()).environmentObject(PreferencesViewModel()))
        contentView.frame = newWindow.contentView!.bounds
        contentView.autoresizingMask = [.width, .height]
        
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor
        newWindow.contentView?.addSubview(contentView, positioned: .above, relativeTo: visualEffectView)

        // Show the window
        if let miniaturizeButton = newWindow.standardWindowButton(.miniaturizeButton) {
                miniaturizeButton.isEnabled = false
                miniaturizeButton.isTransparent = false
                miniaturizeButton.alphaValue = 0.5 // Make it look inactive
            }
            
        if let zoomButton = newWindow.standardWindowButton(.zoomButton) {
            zoomButton.isEnabled = false
            zoomButton.isTransparent = false
            zoomButton.alphaValue = 0.5 // Make it look inactive
        }
    
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        newWindow.orderFrontRegardless()
    }
    
}
    
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environmentObject(TimerManager())
//            .environmentObject(ProViewModel())
//            .environmentObject(TimerViewModel())
//            .environmentObject(SoundModel())
//            .environmentObject(LayoutViewModel())
//            .frame(width: 400, height: 300)
//    }
//}
