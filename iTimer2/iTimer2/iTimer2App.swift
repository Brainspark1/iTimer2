import SwiftUI
import Combine

struct iTimer2App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup(id: "onboard") {
            ContentView()
                .environmentObject(appDelegate.timerManager)
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

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    @Published var contentView = ContentView()
    @Published var timerManager = TimerManager()
    @Published var isPomodoroRunning = false
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
            statusButton.action = #selector(togglePopover)
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 400, height: 400)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView().environmentObject(timerManager).environmentObject(self))
        
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
    
    private func updateStatusItemTitle(remainingTime: Int, isPomodoroRunning: Bool, isBreakTime: Bool, timeName: String) {
        if let button = statusItem.button {
            if isPomodoroRunning {
                let statusText = isBreakTime ? "Break" : "Work"
                button.title = remainingTime > 0 ? "\(statusText): \(timeString(time: remainingTime))" : ""
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
