import SwiftUI
import Combine
import AppKit
import KeyboardShortcuts
import Foundation

// -------------------------------------------------------------
// MARK: - App
// -------------------------------------------------------------
struct iTimer2App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var timerManager = TimerManager(provm: ProViewModel())
    @StateObject private var preferencesvm = PreferencesViewModel()
    @StateObject private var provm = ProViewModel()
    @StateObject private var soundModel = SoundModel()
    @StateObject private var layoutvm = LayoutViewModel()
    @StateObject private var viewModel = TimerViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    init() {
        if UserDefaults.standard.bool(forKey: "proModeTrueBool") {
            preferencesvm.ifRestarted = true
        }
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            if hasCompletedOnboarding {
                ContentViewWrapper()
                    .environmentObject(appDelegate)
                    .environmentObject(timerManager)
                    .environmentObject(provm)
                    .environmentObject(preferencesvm)
                    .environmentObject(soundModel)
                    .environmentObject(layoutvm)
                    .environmentObject(viewModel)
            } else {
                OnboardingView()
                    .environmentObject(appDelegate)
                    .environmentObject(timerManager)
                    .environmentObject(provm)
                    .environmentObject(preferencesvm)
                    .environmentObject(soundModel)
                    .environmentObject(layoutvm)
                    .environmentObject(viewModel)
            }
        }
        .commands {
            CommandGroup(replacing: .windowSize) {
                Button("Toggle Full Screen") { toggleFullScreen() }
                    .keyboardShortcut("f", modifiers: .command)
            }
        }
    }

    func toggleFullScreen() {
        NSApp.mainWindow?.toggleFullScreen(nil)
    }
}

// -------------------------------------------------------------
// MARK: - ContentView Wrapper
// -------------------------------------------------------------
struct ContentViewWrapper: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var preferencesvm: PreferencesViewModel
    @EnvironmentObject var provm: ProViewModel
    @EnvironmentObject var soundModel: SoundModel
    @EnvironmentObject var layoutvm: LayoutViewModel
    @EnvironmentObject var viewModel: TimerViewModel
    @EnvironmentObject var appDelegate: AppDelegate
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        ContentView()
            .environmentObject(appDelegate)
            .environmentObject(timerManager)
            .environmentObject(preferencesvm)
            .environmentObject(provm)
            .environmentObject(soundModel)
            .environmentObject(layoutvm)
            .environmentObject(viewModel)
            .task {
                // Ensure the status bar panel hosts ContentView with the same environment
                appDelegate.rebuildPanelEnvironment(
                    appDelegate: appDelegate,
                    timerManager: timerManager,
                    provm: provm,
                    preferencesvm: preferencesvm,
                    soundModel: soundModel,
                    layoutvm: layoutvm,
                    viewModel: viewModel
                )
                print("Has Completed Onboarding: \(timerManager.hasCompletedOnboarding)")
                if preferencesvm.ifRestarted {
                    print("Has restarted, boolean = true")
                }
            }
            .onChange(of: hasCompletedOnboarding) { _ in
                // Rebuild the panel content when onboarding flips, to keep environments consistent
                appDelegate.rebuildPanelEnvironment(
                    appDelegate: appDelegate,
                    timerManager: timerManager,
                    provm: provm,
                    preferencesvm: preferencesvm,
                    soundModel: soundModel,
                    layoutvm: layoutvm,
                    viewModel: viewModel
                )
            }
    }
}

// -------------------------------------------------------------
// MARK: - PopoverPanel
// -------------------------------------------------------------
final class PopoverPanel: NSPanel {

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    private let visualBackground = NSVisualEffectView()
    private let contentContainer = NSView()

    init(contentViewController: NSViewController, size: NSSize) {
        super.init(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.hudWindow, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isReleasedWhenClosed = false
        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = true
        worksWhenModal = true

        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        level = .popUpMenu
        collectionBehavior = [.transient, .moveToActiveSpace, .ignoresCycle]

        hidesOnDeactivate = false

        backgroundColor = .clear
        isOpaque = false
        hasShadow = true

        visualBackground.material = .hudWindow
        visualBackground.blendingMode = .behindWindow
        visualBackground.state = .active
        visualBackground.translatesAutoresizingMaskIntoConstraints = false
        visualBackground.wantsLayer = true
        visualBackground.layer?.cornerRadius = 12
        visualBackground.layer?.masksToBounds = true

        let hosted = contentViewController.view
        hosted.translatesAutoresizingMaskIntoConstraints = false
        hosted.wantsLayer = true
        hosted.layer?.cornerRadius = 12
        hosted.layer?.masksToBounds = true

        contentContainer.frame = NSRect(origin: .zero, size: size)
        contentContainer.addSubview(visualBackground)
        visualBackground.addSubview(hosted)

        NSLayoutConstraint.activate([
            visualBackground.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            visualBackground.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            visualBackground.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            visualBackground.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),

            hosted.leadingAnchor.constraint(equalTo: visualBackground.leadingAnchor),
            hosted.trailingAnchor.constraint(equalTo: visualBackground.trailingAnchor),
            hosted.topAnchor.constraint(equalTo: visualBackground.topAnchor),
            hosted.bottomAnchor.constraint(equalTo: visualBackground.bottomAnchor)
        ])

        self.contentView = contentContainer

        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true

        alphaValue = 0.0
    }

    // Modified to accept completion so we can start click monitor AFTER animation
    func animateIn(completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().alphaValue = 1.0
        } completionHandler: {
            completion?()
        }
    }

    func animateOut(_ completion: @escaping () -> Void) {
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0.0
        } completionHandler: {
            completion()
        }
    }
}

// -------------------------------------------------------------
// MARK: - App Delegate
// -------------------------------------------------------------
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {

    private var statusItem: NSStatusItem!
    private var panel: PopoverPanel?
    private var isAnimatingClose = false
    private var isStatusButtonPressed = false
    private var outsideClickMonitor: Any?
    private var lastOpenTimestamp: TimeInterval = 0
    private var isOpening = false

    @Published var contentView = ContentView()
    @Published var timerManager = TimerManager(provm: ProViewModel())
    @Published var viewModel = TimerViewModel()
    @Published var isPomodoroRunning = false
    @Published var isStopwatchRunning = false
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
            button.action = #selector(togglePanel)
            button.target = self
            button.sendAction(on: [.leftMouseDown, .rightMouseUp])

            print("[iTimer2] status button configured")
        }

        if let w = statusItem.button?.window {
            w.collectionBehavior = [.transient, .ignoresCycle]
            w.level = .statusBar
            print("[iTimer2] status button window configured: collectionBehavior=\(w.collectionBehavior)")
        }

        buildPanelContent()

        timerManager.$remainingTime
            .combineLatest($isPomodoroRunning, timerManager.$isBreakTime, timerManager.$timeName)
            .receive(on: RunLoop.main)
            .sink { [weak self] remainingTime, isPomodoroRunning, isBreakTime, name in
                self?.updateStatusItemTitle(
                    remainingTime: remainingTime,
                    isPomodoroRunning: isPomodoroRunning,
                    isBreakTime: isPomodoroRunning ? true : isBreakTime,
                    timeName: name
                )
            }
            .store(in: &cancellables)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    private func buildPanelContent() {
        // Provide at least the objects StopwatchView needs right away
        let root = ContentView()
            .environmentObject(self)                 // AppDelegate
            .environmentObject(self.timerManager)    // TimerManager used by panel
            .environmentObject(ProViewModel())       // ProViewModel (you can replace with a shared one later)
            .environmentObject(PreferencesViewModel())
            .environmentObject(SoundModel())
            .environmentObject(LayoutViewModel())
            .environmentObject(self.viewModel)       // TimerViewModel

        let hosting = NSHostingController(rootView: root)
        panel = PopoverPanel(contentViewController: hosting, size: NSSize(width: 255, height: 300))
        print("[iTimer2] panel created (frame \(String(describing: panel?.frame)))")
    }

    func rebuildPanelEnvironment(
        appDelegate: AppDelegate,
        timerManager: TimerManager,
        provm: ProViewModel,
        preferencesvm: PreferencesViewModel,
        soundModel: SoundModel,
        layoutvm: LayoutViewModel,
        viewModel: TimerViewModel
    ) {
        let root = ContentView()
            .environmentObject(appDelegate)
            .environmentObject(timerManager)
            .environmentObject(provm)
            .environmentObject(preferencesvm)
            .environmentObject(soundModel)
            .environmentObject(layoutvm)
            .environmentObject(viewModel)

        let hosting = NSHostingController(rootView: root)
        self.panel = PopoverPanel(contentViewController: hosting, size: NSSize(width: 255, height: 300))
        print("[iTimer2] panel rebuilt with environments")
    }

    // MARK: - Toggle Panel
    @objc private func togglePanel() {
        // Avoid race if closing animation running or currently opening
        if isAnimatingClose || isOpening { return }

        guard let button = statusItem.button, let panel = panel else { return }

        // Mark that the button was pressed (for resignActive logic)
        isStatusButtonPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.isStatusButtonPressed = false
        }

        if panel.isVisible && panel.alphaValue > 0 {
            closePanelAnimated()
        } else {
            showPanel(below: button, animated: true)
        }
    }

    // MARK: - Show Panel
    private func showPanel(below button: NSStatusBarButton, animated: Bool) {
        if isAnimatingClose { return }
        guard let panel = panel, let window = button.window else { return }

        lastOpenTimestamp = ProcessInfo.processInfo.systemUptime

        let buttonFrame = button.convert(button.bounds, to: nil)
        let screenFrame = window.convertToScreen(buttonFrame)
        let size = panel.frame.size
        let x = round(screenFrame.midX - size.width / 2)
        let y = round(screenFrame.minY - size.height - 6)
        let targetFrame = NSRect(x: x, y: y, width: size.width, height: size.height)
        panel.setFrame(targetFrame, display: true)

        panel.ignoresMouseEvents = false
        panel.acceptsMouseMovedEvents = true
        panel.becomesKeyOnlyIfNeeded = true

        // Use makeKeyAndOrderFront so the panel is really treated as key on Sequoia
        panel.alphaValue = 0.0
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(nil)

        // Animate in, then start outside-click monitor AFTER animation finishes
        panel.animateIn { [weak self] in
            self?.isOpening = false
            self?.startOutsideClickMonitor()
        }
    }

    // MARK: - Close Panel
    public func closePanelAnimated() {
        guard let panel = panel, panel.isVisible, !isAnimatingClose else { return }
        isAnimatingClose = true

        stopOutsideClickMonitor()

        panel.animateOut { [weak self] in
            self?.panel?.orderOut(nil)
            self?.isAnimatingClose = false
            print("[iTimer2] panel closed")
        }
    }

    // MARK: - didResignActive (Sequoia quirk)
    @objc private func appDidResignActive() {
        guard let panel = panel else { return }

        let now = ProcessInfo.processInfo.systemUptime

        // Ignore resignActive that fires immediately after opening (status item quirk)
        if now - lastOpenTimestamp < 0.5 {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            if panel.isVisible && !NSApp.isActive && !self.isStatusButtonPressed {
                self.closePanelAnimated()
            }
        }
    }

    // MARK: - Outside-click monitor
    private func startOutsideClickMonitor() {
        guard outsideClickMonitor == nil else { return }
        guard let panel = panel else { return }

        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let panel = self.panel else { return }
            if !panel.isVisible { return }

            // 1. Ignore clicks on the status bar item window itself
            if let evWindow = event.window,
               evWindow.className == "NSStatusBarWindow" {
                return
            }

            // 2. Ignore clicks inside the panel
            let mouseLoc = NSEvent.mouseLocation // global screen coords
            if panel.frame.contains(mouseLoc) {
                return
            }

            // 3. Click was outside → close
            DispatchQueue.main.async {
                self.closePanelAnimated()
            }
        }
    }

    private func stopOutsideClickMonitor() {
        if let monitor = outsideClickMonitor {
            NSEvent.removeMonitor(monitor)
            outsideClickMonitor = nil
        }
    }

    // MARK: - Status Item Title
    private func updateStatusItemTitle(remainingTime: Int, isPomodoroRunning: Bool, isBreakTime: Bool, timeName: String) {
        guard let button = statusItem.button else { return }

        if isPomodoroRunning {
            button.title = ""
        } else {
            button.title = remainingTime > 0
                ? "\(timeString(time: remainingTime)) (\(timeName))"
                : "\(timeName)"
        }
    }

    private func timeString(time: Int) -> String {
        let h = time / 3600
        let m = (time % 3600) / 60
        let s = time % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
