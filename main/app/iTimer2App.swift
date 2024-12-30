import SwiftUI
import Combine
import AppKit
import KeyboardShortcuts

struct iTimer2App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var timerManager = TimerManager()
    @StateObject private var preferencesvm = PreferencesViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    init() {
            // This block runs when the app launches
            if UserDefaults.standard.bool(forKey: "proModeTrueBool") {
                preferencesvm.ifRestarted = true
                // Reset the value so it only applies once after restart
            }
        }
    
    var body: some Scene {
        WindowGroup(id: "main") {
            if hasCompletedOnboarding {
                ContentViewWrapper()
                    .environmentObject(timerManager)
                    .environmentObject(ProViewModel())
                    .environmentObject(PreferencesViewModel())
            } else {
                OnboardingView()
                    .environmentObject(timerManager)
            }
        }
        .commands {
            CommandGroup(replacing: .windowSize) {
                Button("Toggle Full Screen") {
                    toggleFullScreen()
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }
    }
    
    func toggleFullScreen() {
        if let window = NSApp.mainWindow {
            window.toggleFullScreen(nil)
        }
    }
}

struct ContentViewWrapper: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var preferencesvm: PreferencesViewModel
    
    var body: some View {
        ContentView().environmentObject(SoundModel()).environmentObject(LayoutViewModel())
            .task {
                print("Has Completed Onboarding: \(hasCompletedOnboarding)")
            }
            .onAppear() {
                if preferencesvm.ifRestarted {
                    print("Has restarted, boolean = true")
                }
            }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    @Published var contentView = ContentView()
    @Published var timerManager = TimerManager()
    @Published var viewModel = TimerViewModel()
    @Published var isPomodoroRunning = false
    @Published var isStopwatchRunning = false
    private var cancellables = Set<AnyCancellable>()
    
    func application(_ sender: NSApplication, open url: URL) {
            // Extract the timer parameters from the URL
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems {
                let name = queryItems.first(where: { $0.name == "name" })?.value ?? "Default Timer"
                let duration = queryItems.first(where: { $0.name == "duration" })?.value ?? "60" // default to 60 seconds
                
                if let duration = Int(duration) {
                    // Start a new timer with the extracted parameters
                    timerManager.startNewTimer(hours: 0, minutes: 0, seconds: duration, name: name)
                }
            }
        }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
            statusButton.action = #selector(togglePopover)
            
            openAppShortcut()
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 400, height: 400)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView()
            .environmentObject(timerManager)
            .environmentObject(ProViewModel())
            .environmentObject(TimerViewModel())
            .environmentObject(SoundModel())
            .environmentObject(LayoutViewModel())
            .environmentObject(self))
        
        // Combine the publishers for the timerManager's remainingTime and isPomodoroRunning
        timerManager.$remainingTime
            .combineLatest($isPomodoroRunning, timerManager.$isBreakTime, timerManager.$timeName)
            .receive(on: RunLoop.main)
            .sink { [weak self] remainingTime, isPomodoroRunning, isBreakTime, timeName in
                self?.updateStatusItemTitle(remainingTime: remainingTime, isPomodoroRunning: isPomodoroRunning, isBreakTime: isBreakTime, timeName: timeName)
            }
            .store(in: &cancellables)
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    func openAppShortcut() {
        KeyboardShortcuts.onKeyUp(for: .openApp) { [weak self] in
                    self?.togglePopover()
                }
    }
    
    private func updateStatusItemTitle(remainingTime: Int, isPomodoroRunning: Bool, isBreakTime: Bool, timeName: String) {
        if let button = statusItem.button {
            if isPomodoroRunning {
                let statusText = isBreakTime ? "Break" : "Work"
                button.title = ""
                // viewModel.timeRemaining > 0 ? "\(statusText): \(timeString(time: viewModel.timeRemaining))" : 
            } else {
                button.title = remainingTime > 0 ? "\(timeString(time: remainingTime)) (\(timeName))" : "\(timeName)"
            }
        }
    }
    
    private func timeString(time: Int) -> String {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return String (format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
}
