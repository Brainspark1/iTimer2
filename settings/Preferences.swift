import Foundation
import SwiftUI
import AppKit
import Cocoa
import ServiceManagement
import LaunchAtLogin
import Combine
import AVFoundation
import UserNotifications

class TransToggle: ObservableObject {
    
    @State var transApp: Bool = false
}

struct GeneralView: View {
    
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @EnvironmentObject var timerManager: TimerManager
    
    let un = UNUserNotificationCenter.current()
    
    var body: some View {
        
        VStack {
            
            Text("iTimer2")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundColor(.green)
                .shadow(color: .mint, radius: 30)
            
            Text("Version: \(getAppVersion())")
                .font(.title3)
                .padding()
            
            LaunchAtLogin.Toggle("Launch on start")
                .toggleStyle(.switch)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray, lineWidth: 0.5)
                )
            
            HStack {
                
                Toggle("Notifications", isOn: $timerManager.notificationsEnabled)
                    .toggleStyle(.switch)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 0.5)
                    )
                    .onChange(of: timerManager.notificationsEnabled) {
                        if timerManager.notificationsEnabled {
                            notifyUserPermissions()
                        }
                    }
                
                InfoButtonRight(content: "Your Mac will send you a notification when your timer has finished")
            }
        }
    }
    
    func getAppVersion() -> String {
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                return appVersion
            }
            return "Unknown"
        }
    
    func notifyUserPermissions() {
        un.requestAuthorization(options: [.alert, .sound]) { (authorized, error ) in
            if authorized {
                print("Authorized")
            } else if !authorized {
                print("Not Authorized")
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
}

struct KeyView: View {
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                Image(systemName: "arrow.right.circle")
                Text("Start/Pause")
                Text("⌘ + ⏎")
                Spacer()
                Image(systemName: "xmark.circle")
                Text("Stop")
                Text("⌘ + ⇧ + ⏎")
                Spacer()
            }
            
            HStack {
                Spacer()
                Image(systemName: "chevron.up")
                    .foregroundColor(.red)
                Text("Open Pomodoro Mode")
                Text("⌘ + 1")
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.red)
                Text("Close Pomodoro Mode")
                Text("⌘ + ⇧ + 1")
                Spacer()
            }
            .padding()
            
            HStack {
                Spacer()
                Image(systemName: "stopwatch")
                Text("Open Stopwatch")
                Text("⌘ + 2")
                Spacer()
                Image(systemName: "xmark.circle")
                Text("Close Stopwatch")
                Text("⌘ + ⇧ + 2")
                Spacer()
            }
            
            HStack {
                Spacer()
                Image(systemName: "list.bullet.clipboard")
                Text("Show History")
                Text("⌘ + Y")
                Spacer()
                Image(systemName: "pip.exit")
                Text("Popout Timer")
                Text("⌘ + =")
                Spacer()
            }
            .padding()
            
            HStack {
                Spacer()
                Image(systemName: "gear.badge")
                Text("Preferences")
                Text("⌘ + ,")
                Spacer()
                Image(systemName: "exclamationmark.octagon")
                    .foregroundColor(.red)
                Text("Quit")
                Text("⌘ + Q")
                Spacer()
            }
            
            HStack {
                Spacer()
                Image(systemName: "arrow.up.bin")
                Text("Toggle Only Timer Mode")
                Text("⌘ + ⇧ + ⌥ + T")
                Spacer()
            }
            .padding()
            
            Text("Note: Click the Timer to open it out in a Popout view.")
                .font(.subheadline)
                .padding()
            
        }
    }
}

struct LayoutView: View {
    
    @EnvironmentObject private var layoutvm: LayoutViewModel
    @EnvironmentObject private var provm: ProViewModel
    @State private var showPopover = false
    
    var body: some View {
        
        HStack(spacing: 20) {
            Button(action: {
                showPopover.toggle()
            }) {
                Image(systemName: "questionmark.circle")
                    .font(.title3)
            }
            .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                Text("Show which feature buttons are on your screen - don't worry, you can still access them with keyboard shortcuts!")
                    .padding()
            }
            .buttonStyle(BorderlessButtonStyle())
            
            Toggle("Show Pomodoro", isOn: $layoutvm.showPomButton)
            Toggle("Show Stopwatch", isOn: $layoutvm.showStopwatchButton)
            Toggle("Show History", isOn: $layoutvm.showHistoryButton)
        }
        .padding(40)
        
        if provm.proTrue {
            Toggle("Only Timer", isOn: $layoutvm.onlyTimerMode)
                .toggleStyle(.switch)
                .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut("t", modifiers: [.command, .shift, .option]))
        }
        
        Spacer()
        
    }
}

struct TimerView: View {
    @Binding var fontSize: CGFloat
    @AppStorage("workDuration") private var workDuration: String = "25" // Stored in minutes
    @AppStorage("breakDuration") private var breakDuration: String = "5"  // Stored in minutes
    @State private var showPopover = false
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var soundModel: SoundModel
    @EnvironmentObject var provm: ProViewModel
    @State private var audioPlayer: AVAudioPlayer?
    
    let soundFiles = ["none","alarm", "notification", "scanner"]

    var body: some View {
        VStack {
            Slider(
                value: $fontSize,
                in: 25...50,
                step: 5
            ) {
                Text("Timer Size")
                    .padding(.trailing, 2)
            }
            .padding()
            
            HStack {
                Text("Pomodoro Timer Adjustments:")
                    .padding()
                    .font(.title2)
                
                Button(action: {
                    showPopover.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.title3)
                }
                .popover(isPresented: $showPopover, attachmentAnchor: .point(.trailing), arrowEdge: .trailing) {
                    Text("Adjust the durations of the work and break stages in Pomodoro Mode")
                        .padding()
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            HStack {
                VStack {
                    Text("Work Duration (min)")
                    TextField("Enter work duration", text: $workDuration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: workDuration) { newValue in
                            validateAndSetDuration(newValue: newValue, isWorkDuration: true)
                        }
                }
                
                VStack {
                    Text("Break Duration (min)")
                    TextField("Enter break duration", text: $breakDuration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: breakDuration) { newValue in
                            validateAndSetDuration(newValue: newValue, isWorkDuration: false)
                        }
                }
            }
            
            if provm.proTrue {
                HStack {
                    Picker("Alarm Sound", selection: $soundModel.selectedSound) {
                        ForEach(soundFiles, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    
                    Button("Preview Sound", action: playSound)
                        .padding()
                }
            }
        }
    }
    
    func validateAndSetDuration(newValue: String, isWorkDuration: Bool) {
        if newValue.isEmpty {
            // Allow empty input while the user is editing
            if isWorkDuration {
                timerViewModel.setWorkDuration(0) // Set to 0 but allow further editing
            } else {
                timerViewModel.setBreakDuration(0) // Set to 0 but allow further editing
            }
        } else if let duration = Int(newValue), duration > 0 {
            // If valid, update the timer duration
            if isWorkDuration {
                timerViewModel.setWorkDuration(duration)
            } else {
                timerViewModel.setBreakDuration(duration)
            }
        } else {
            // If the input is invalid (not a number), revert to the previous valid value
            if isWorkDuration {
                workDuration = "\(timerViewModel.workDuration)"
            } else {
                breakDuration = "\(timerViewModel.breakDuration)"
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
}

struct ProView: View {
    
    @EnvironmentObject var provm: ProViewModel
    
    var body: some View {
        
        Spacer()
        
        Form {
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                Text("Customisable Keyboard Shortcuts")
            }
            .padding(2)
            
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                Text("Timer and History Presets")
            }
            .padding(2)
            
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                Text("Progress Bars")
            }
            .padding(2)
            
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                Text("Alarm Sounds")
            }
            .padding(2)
            
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                Text("...and more!")
            }
            .padding(2)
        }
        
        Spacer()
        
        Text("Buy iTimer 2 Pro")
            .font(.title)
        Text("£2.99")
            .font(.title2)
            .opacity(0.5)
            .padding()
        
        Button("Go Pro") {
            
            provm.proTrue = true
            openProOnboarding()
            UserDefaults.standard.set(true, forKey: "proModeTrueBool")
            
        }
        .shadow(color: .green, radius: 5)
        
        if provm.proTrue {
            Text("You're now Pro!")
                .padding()
        }
        
        Spacer()
    }
    
    func openProOnboarding() {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 750, height: 450),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered, defer: false)
        let onboardIdentifier = NSUserInterfaceItemIdentifier("proonboarding")
        
        newWindow.center()
        newWindow.title = "Pro Onboarding Screen"
        newWindow.identifier = onboardIdentifier
        newWindow.isReleasedWhenClosed = false
        
        let onboardingView = NewProOnboardingView()
            .frame(width: 750, height: 425)
        
        newWindow.contentView = NSHostingView(rootView: onboardingView.environmentObject(TimerManager()))
        newWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
        newWindow.standardWindowButton(.zoomButton)?.isHidden = true
        
        //hide title and bar
        newWindow.titleVisibility = .hidden
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
    }
}

struct DevNewOnboardingView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if selectedTab == 0 {
                NewOnboard1View(selectedTab: $selectedTab)
            } else if selectedTab == 1 {
                NewOnboard2View(selectedTab: $selectedTab)
                    .environmentObject(TimerManager())
            } else if selectedTab == 2 {
                NewOnboard3View(selectedTab: $selectedTab)
            } else if selectedTab == 3 {
                NewOnboard4View(selectedTab: $selectedTab)
            } else if selectedTab == 4 {
                NewOnboard5View(selectedTab: $selectedTab)
            } else if selectedTab == 5 {
                NewOnboard6View(selectedTab: $selectedTab)
            } else if selectedTab == 6 {
                NewOnboard7View(selectedTab: $selectedTab)
            } else if selectedTab == 7 {
                NewOnboard8View(selectedTab: $selectedTab)
            } else if selectedTab == 8 {
                NewOnboard9View(selectedTab: $selectedTab)
                    .environmentObject(TimerManager())
            }
        }
    }
}
    
    struct DeveloperPreferencesView: View {
        
        @EnvironmentObject var timerManager: TimerManager
        @EnvironmentObject var provm: ProViewModel
        let textToCopy: String = "https://github.com/Brainspark1/iTimer2"
        
        var body: some View {
            
            HStack {
                Text("https://github.com/Brainspark1/iTimer2")
                    .padding()
                
                Button(action: {
                    copyToClipboard(textToCopy)
                }) {
                    Text("Copy Link")
                }
                
                Spacer()
            }
            .padding(23)
            
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            
            HStack {
                Spacer()
                
                Button("End Pro") {
                    provm.proTrue = false
                }
                
                Button("Open Onboarding", action: openOnboarding)
                    .padding()
            }
            .padding(10)
            .padding(.bottom, 10)
        }
        
        func openOnboarding() {
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 750, height: 450),
                styleMask: [.titled, .closable, .resizable, .miniaturizable],
                backing: .buffered, defer: false)
            
            newWindow.center()
            newWindow.title = "Onboarding Screen"
            newWindow.isReleasedWhenClosed = false
            
            let onboardingView = DevNewOnboardingView()
                .frame(width: 750, height: 425)
            
            newWindow.contentView = NSHostingView(rootView: onboardingView)
            newWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
            newWindow.standardWindowButton(.zoomButton)?.isHidden = true
            
            //hide title and bar
            newWindow.titleVisibility = .hidden
            newWindow.makeKeyAndOrderFront(nil)
            newWindow.orderFrontRegardless()
        }
        
        func copyToClipboard(_ text: String) {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)
        }
        
    }

//struct PreferencesView: View {
//        
//        @Binding var fontSize: CGFloat
//        @Binding var notificationsEnabled
//        @EnvironmentObject var provm: ProViewModel
//        
//        var keyboardView: AnyView {
//            if provm.proTrue {
//                return AnyView(ChooseView().environmentObject(PreferencesViewModel()))
//            } else {
//                return AnyView(KeyView())
//            }
//        }
//        
//        var body: some View {
//            
//            CustomTabView(
//                content: [
//                    (
//                        title: "General",
//                        icon: "gear.badge",
//                        view: AnyView(
//                            GeneralView(notificationsEnabled: <#Binding<Bool>#>)
//                        )
//                    ),
//                    (
//                        title: "Timer",
//                        icon: "paintbrush.fill",
//                        view: AnyView(
//                            TimerView(fontSize: $fontSize)
//                                .environmentObject(SoundModel())
//                                .environmentObject(ProViewModel())
//                        )
//                    ),
//                    (
//                        title: "Layout",
//                        icon: "square.text.square",
//                        view: AnyView(
//                            LayoutView()
//                                .environmentObject(LayoutViewModel())
//                        )
//                    ),
//                    (
//                        title: "Keyboard",
//                        icon: "keyboard.badge.ellipsis",
//                        view: keyboardView
//                    ),
//                    (
//                        title: "iTimer2 Pro",
//                        icon: "star.circle",
//                        view: AnyView (
//                            ProView()
//                                .environmentObject(ProViewModel())
//                        )
//                    ),
//                    (
//                        title: "Developer",
//                        icon: "wrench.and.screwdriver.fill",
//                        view: AnyView (
//                            DeveloperPreferencesView()
//                                .environmentObject(ProViewModel())
//                        )
//                    )
//                ]
//            )
//            
//        }
//    }

enum PreferencesSection: String, CaseIterable, Identifiable {
    case general = "General"
    case timer = "Timer"
    case layout = "Layout"
    case keyboard = "Keyboard"
    case pro = "Pro"
    case dev = "Developer"
    
    var id: String { self.rawValue }
    
    @ViewBuilder
    func view(fontSize: Binding<CGFloat>, viewModel: ProViewModel) -> some View {
        switch self {
        case .general:
            GeneralView()
                .environmentObject(TimerManager())
        case .timer:
            TimerView(fontSize: fontSize)
                .environmentObject(TimerViewModel())
        case .layout:
            LayoutView()
                .environmentObject(ProViewModel())
        case .keyboard:
            if viewModel.proTrue {
                ChooseView()
            } else {
                KeyView() // Replace with your alternative view
            }
        case .pro:
            ProView()
        case .dev:
            DeveloperPreferencesView()
        }
    }
}

struct ListPreferencesView: View {
    @EnvironmentObject var viewModel: ProViewModel
    @State private var selectedSection: PreferencesSection = .general
    @Binding var fontSize: CGFloat
    
    var body: some View {
        VStack {
            Spacer().frame(height: 20)
            
            NavigationView {
                List(PreferencesSection.allCases, selection: $selectedSection) { section in
                    NavigationLink(destination: section.view(fontSize: $fontSize, viewModel: viewModel)) {
                        Text(section.rawValue)
                            .padding(3)
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(width: 150)
                
                selectedSection.view(fontSize: $fontSize, viewModel: viewModel)
                    .frame(minWidth: 400)
                    .padding()
            }
            .navigationTitle("Preferences")
            .frame(width: 750, height: 450)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}
