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
    @StateObject var provm = ProViewModel()
    
    let un = UNUserNotificationCenter.current()
    
    var body: some View {
        
        VStack {
            
            Text("iTimer2")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundColor(.green)
                .shadow(color: .mint, radius: 30)
            
            HStack {
                
                if provm.proTrue {
                    Text("Version: \(getAppVersion())")
                        .font(.title3)
                        .padding([.leading, .top, .bottom])
                } else {
                    Text("Version: \(getAppVersion())")
                        .font(.title3)
                        .padding()
                }
                
                if provm.proTrue {
                    Text("(Pro)")
                        .font(.title3)
                        .padding(.trailing)
                }
                
            }
            
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

//struct LayoutView: View {
//    
//    @EnvironmentObject private var layoutvm: LayoutViewModel
//    @EnvironmentObject private var provm: ProViewModel
//    @State private var showPopover = false
//    
//    var body: some View {
//        
//        HStack(spacing: 20) {
//            Button(action: {
//                showPopover.toggle()
//            }) {
//                Image(systemName: "questionmark.circle")
//                    .font(.title3)
//            }
//            .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
//                Text("Show which feature buttons are on your screen - don't worry, you can still access them with keyboard shortcuts!")
//                    .padding()
//            }
//            .buttonStyle(BorderlessButtonStyle())
//            
//            Toggle("Show Pomodoro", isOn: $layoutvm.showPomButton)
//            Toggle("Show Stopwatch", isOn: $layoutvm.showStopwatchButton)
//            Toggle("Show History", isOn: $layoutvm.showHistoryButton)
//        }
//        .padding(40)
//        
//        if provm.proTrue {
//            Toggle("Only Timer", isOn: $layoutvm.onlyTimerMode)
//                .toggleStyle(.switch)
//                .conditionalKeyboardShortcut(isEnabled: !provm.proTrue, KeyboardShortcut("t", modifiers: [.command, .shift, .option]))
//        }
//        
//        Spacer()
//        
//    }
//}

import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct TimerView: View {
    @Binding var fontSize: CGFloat
    @AppStorage("workDuration") private var workDuration: String = "25"
    @AppStorage("breakDuration") private var breakDuration: String = "5"
    @State private var showPopover = false
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var soundModel: SoundModel
    @EnvironmentObject var provm: ProViewModel
    @State private var audioPlayer: AVAudioPlayer?
    @State var showManageSoundsSheet = false

    @State private var hoveringSound: String?
    @State private var lastValidSelection: String = "alarm"

    let defaultSounds = ["none", "alarm", "notification", "scanner"]
    let uploadLabel = "Upload Custom Sound..."

    var body: some View {
        VStack {
            // Font Size Slider
            Slider(value: $fontSize, in: 42...50, step: 2) {
                Text("Timer Size")
                    .padding(.trailing, 2)
            }
            .padding()

            // Timer Adjustments
            HStack {
                Text("Pomodoro Timer Adjustments:")
                    .padding()
                    .font(.title2)

                Button(action: { showPopover.toggle() }) {
                    Image(systemName: "questionmark.circle")
                        .font(.title3)
                }
                .popover(isPresented: $showPopover, attachmentAnchor: .point(.trailing), arrowEdge: .trailing) {
                    Text("Adjust the durations of the work and break stages in Pomodoro Mode")
                        .padding()
                }
                .buttonStyle(BorderlessButtonStyle())
            }

            // Duration Text Fields
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

            // Sound Picker
            if provm.proTrue {
                HStack {
                    Picker("Alarm Sound", selection: $soundModel.selectedSound) {
                        // Default sounds
                        ForEach(defaultSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }

                        // Uploaded sounds
                        ForEach(Array(soundModel.uploadedSounds.keys), id: \.self) { sound in
                            HStack {
                                Text(sound)
                                if hoveringSound == sound {
                                    Spacer()
                                    Button {
                                        soundModel.removeSound(named: sound)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(width: 20, height: 20)
                                }
                            }
                            .tag(sound)
                            .onHover { hovering in
                                hoveringSound = hovering ? sound : nil
                            }
                        }
                        
                        Divider()

                        // Upload sound
                        Text(uploadLabel)
                            .tag(uploadLabel)
                    }
                    .onChange(of: soundModel.selectedSound) { newValue in
                        if newValue == uploadLabel {
                            selectWavFile()
                            soundModel.selectedSound = lastValidSelection
                        } else {
                            lastValidSelection = newValue
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(minWidth: 150)
                    .padding()
                    
                    Button(action: {
                        playSound()
                    }) {
                        Text("Preview Sound")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing)
                    
                }
                .sheet(isPresented: $showManageSoundsSheet) {
                    ManageUploadedSoundsView()
                        .environmentObject(soundModel)
            }

                Button(action: {
                    showManageSoundsSheet.toggle()
                }) {
                    Text("Manage Uploaded Sounds")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading)
            
                }
        }
    }

    @ViewBuilder
    func soundRow(title: String, isCustom: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()

            if soundModel.selectedSound == title {
                Image(systemName: "checkmark")
            }

            if isCustom, hoveringSound == title {
                Button(action: {
                    soundModel.removeSound(named: title)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            soundModel.selectedSound = title
            lastValidSelection = title
        }
        .onHover { hovering in
            hoveringSound = hovering ? title : nil
        }
        .padding(.horizontal, 4)
    }

    func validateAndSetDuration(newValue: String, isWorkDuration: Bool) {
        if newValue.isEmpty {
            if isWorkDuration {
                timerViewModel.setWorkDuration(0)
            } else {
                timerViewModel.setBreakDuration(0)
            }
        } else if let duration = Int(newValue), duration > 0 {
            if isWorkDuration {
                timerViewModel.setWorkDuration(duration)
            } else {
                timerViewModel.setBreakDuration(duration)
            }
        } else {
            if isWorkDuration {
                workDuration = "\(timerViewModel.workDuration)"
            } else {
                breakDuration = "\(timerViewModel.breakDuration)"
            }
        }
    }

    func playSound() {
        let selected = soundModel.selectedSound

        if let url = soundModel.uploadedSounds[selected] {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Failed to play uploaded sound: \(error.localizedDescription)")
            }
        } else if selected != "none",
                  let bundledURL = Bundle.main.url(forResource: selected, withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: bundledURL)
                audioPlayer?.play()
            } catch {
                print("Failed to play bundled sound: \(error.localizedDescription)")
            }
        }
    }

    func selectWavFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.wav]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let selectedURL = panel.url {
            soundModel.addSound(from: selectedURL)
        }
    }
}

struct ProView: View {
    
    @EnvironmentObject var provm: ProViewModel
    @Environment(\.openURL) var openURL
    
    var body: some View {
        
        Spacer()
        
//        Button(action: {
//            provm.upgradeButtonIsClosed = true
//        }) {
//            Text("Dismiss Upgrade Button")
//        }
//        .buttonStyle(.plain)
//        
//        Spacer()
        
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
        
        Button(action: {
            if let url = URL(string: "https://sunny-sprinkles-2539a3.netlify.app") {
                openURL(url)
            }
            
            openProPasswordField()
        }) {
            Text("Go Pro")
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.green)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 102, height: 26)
        .shadow(color: .green, radius: 10)
        
        
        
        if provm.proTrue == true {
            Text("You're now Pro!")
                .padding()
        }
        
        Spacer()
    }
    
    func openProPasswordField() {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 450),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered, defer: false)
        let onboardIdentifier = NSUserInterfaceItemIdentifier("proPassField")
        
        newWindow.center()
        newWindow.title = "Pro Password Field"
        newWindow.identifier = onboardIdentifier
        newWindow.isReleasedWhenClosed = false
        
        let onboardingView = ProPasswordFieldView()
            .frame(width: 300, height: 425)
        
        newWindow.contentView = NSHostingView(rootView: onboardingView.environmentObject(ProViewModel()))
        newWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
        newWindow.standardWindowButton(.zoomButton)?.isHidden = true
        
        //hide title and bar
        newWindow.titleVisibility = .hidden
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
        
        provm.passwordWindow = newWindow
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
        
        newWindow.contentView = NSHostingView(rootView: onboardingView.environmentObject(TimerManager(provm: ProViewModel())))
        newWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
        newWindow.standardWindowButton(.zoomButton)?.isHidden = true
        
        //hide title and bar
        newWindow.titleVisibility = .hidden
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
    }
}

struct ProPasswordFieldView: View {
    @EnvironmentObject var provm: ProViewModel
    @State private var passIsCorrect: Bool? = nil
    @State private var showCloseText: Bool = false
    
    var body: some View {
        Text("Enter the license key that you were given at the end of filling out the Payment Form.")
            .padding()
        
        SecureField("", text: $provm.userProPassword)
//            .onChange(of: provm.userProPassword) {
//                    if provm.userProPassword == provm.actualProPassword {
//                        provm.proTrue = true
//                        print("Password Correct")
//                        openProOnboarding()
//                        
//                        UserDefaults.standard.set(true, forKey: "proModeTrueBool")
//                }
//            }
            .padding()
        
        Button(action: {
            if provm.userProPassword == provm.actualProPassword {
                print(provm.proTrue)
                provm.proTrue = true
                print(provm.proTrue)
                passIsCorrect = true
                provm.passwordWindow?.close()
                print("Key correct!")
                UserDefaults.standard.set(true, forKey: "proModeTrueBool")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    openProOnboarding()
                    showCloseText = true
                }
            }
            
            if provm.userProPassword != provm.actualProPassword {
                passIsCorrect = false
            }
        }) {
            Text("Check Key")
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .padding()
        .fixedSize()
        .buttonStyle(PlainButtonStyle())
        .frame(width: 112, height: 26)
        
        if passIsCorrect == true {
            Text("Correct Key ✅")
                .padding()
            if !showCloseText {
                Text("Please wait...")
            } else if showCloseText {
                Text("You may now close this window")
                    .padding()
            }
            
        } else if passIsCorrect == false {
            Text("Incorrect Key ❌")
    }
        
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
        
        newWindow.contentView = NSHostingView(rootView: onboardingView.environmentObject(TimerManager(provm: ProViewModel())))
        newWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
        newWindow.standardWindowButton(.zoomButton)?.isHidden = true
        
        //hide title and bar
        newWindow.titleVisibility = .hidden
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
    }
}

struct HelpAndFeedbackView: View {
    
    @State private var buttonText = "Copy Address"
    let addressToCopy = "brainsparkteam@gmail.com"

        var body: some View {
            Text("We'd love to hear from you! Feel free to reach out with any questions or feedback.")
                .opacity(0.8)
            
            HStack {
                Text("Contact/Support Email: brainsparkteam@gmail.com")
                
                Button(action: {
                    copyToClipboard(addressToCopy)
                    buttonText = "Copied!"
                    
                    // Reset the button text after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        buttonText = "Copy Address"
                    }
                }) {
                    Text(buttonText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
                
            }
        }

        func copyToClipboard(_ text: String) {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)
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
                    .environmentObject(TimerManager(provm: ProViewModel()))
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
                NewOnboard10View(selectedTab: $selectedTab)
                    .environmentObject(TimerManager(provm: ProViewModel()))
            }
        }
    }
}
    
    struct DeveloperPreferencesView: View {
        
        @EnvironmentObject var timerManager: TimerManager
        @EnvironmentObject var provm: ProViewModel
        let textToCopy: String = "https://github.com/Brainspark1/iTimer2"
        let otherTextToCopy: String = "https://brainsparkteam.wixstudio.com/itimer2"
        @Environment(\.openURL) var openURL
        @State private var showOnboardingAlert: Bool = false
        
        var body: some View {
            
            HStack {
                Button(action: {
                    if let url = URL(string: "https://github.com/Brainspark1/iTimer2") {
                        openURL(url)
                    }
                }) {
                    Text("Github: github.com/Brainspark1/iTimer2")
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    if let url = URL(string: "https://github.com/Brainspark1/iTimer2") {
                        openURL(url)
                    }
                }) {
                    Text("Open Link")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .frame(width: 112, height: 26)
                
                Spacer()
            }
            .padding([.top, .leading, .trailing], 23)
            
            HStack {
                Button(action: {
                    if let url = URL(string: "https://brainsparkteam.wixstudio.com/itimer2") {
                        openURL(url)
                    }
                }) {
                    Text("Website: brainsparkteam.wixstudio.com/itimer2")
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    if let url = URL(string: "https://brainsparkteam.wixstudio.com/itimer2") {
                        openURL(url)
                    }
                }) {
                    Text("Open Link")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .frame(width: 112, height: 26)
                
                Spacer()
            }
            .padding([.top, .leading, .trailing], 23)
            
            HStack {
                Button(action: {
                    if let url = URL(string: "https://itimer2updates.substack.com") {
                        openURL(url)
                    }
                }) {
                    Text("Updates Newsletter: itimer2updates.substack.com")
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    if let url = URL(string: "https://itimer2updates.substack.com") {
                        openURL(url)
                    }
                }) {
                    Text("Open Link")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .frame(width: 112, height: 26)
                
                Spacer()
            }
            .padding([.top, .leading, .trailing], 23)
            
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    provm.proTrue = false
                }) {
                    Text("End Pro")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .buttonStyle(PlainButtonStyle())
                
                VStack {
                    
//                    if provm.proTrue == true {
//                        Button(action: {
//                            openProOnboarding()
//                        }) {
//                            Text("Open Pro Onboarding")
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 6)
//                                .background(.black)
//                                .foregroundColor(.white)
//                                .cornerRadius(8)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .fixedSize()
//                        .padding()
//                    }
//                    
                    Button(action: {
                        if !provm.proTrue {
                            openOnboarding()
                        } else {
                            showOnboardingAlert = true
                        }
                    }) {
                        if !provm.proTrue {
                            Text("Open Onboarding")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        } else {
                            Text("Open Onboarding...")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .fixedSize()
                    
                }
                
                Button(action: {
                    timerManager.fullyClearHistory()
                }) {
                    Text("Clear History JSON")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .fixedSize()
                .padding()
                
                Button(action: {
                    DispatchQueue.main.async {
                        TextFileExporter.export(items: timerManager.history.map { $0.timestampDescription })
                    }
                }) {
                    Text("Export Logs")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
            }
            .padding(10)
            .padding(.bottom, 10)
            .alert("Which Onboarding?", isPresented: $showOnboardingAlert) {
                Button("Pro") {
                    openProOnboarding()
                }
                Button("Free") {
                    openOnboarding()
                }
            } message: {
                Text("Which Onboarding view would you like to view?")
            }
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
            
            newWindow.contentView = NSHostingView(rootView: onboardingView.environmentObject(TimerManager(provm: ProViewModel())))
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
//    case layout = "Layout"
    case keyboard = "Keyboard"
    case pro = "Pro"
    case feed = "Help & Feedback"
    case dev = "Developer"
    
    var id: String { self.rawValue }
    
    @ViewBuilder
    func view(fontSize: Binding<CGFloat>, viewModel: ProViewModel) -> some View {
        switch self {
        case .general:
            GeneralView()
                .environmentObject(TimerManager(provm: ProViewModel()))
        case .timer:
            TimerView(fontSize: fontSize)
                .environmentObject(TimerViewModel())
//        case .layout:
//            LayoutView()
//                .environmentObject(ProViewModel())
        case .keyboard:
            if viewModel.proTrue {
                ChooseView()
            } else {
                KeyView() // Replace with your alternative view
            }
        case .pro:
            ProView()
        case .feed:
            HelpAndFeedbackView()
        case .dev:
            DeveloperPreferencesView()
                .environmentObject(TimerManager(provm: ProViewModel()))
                .environmentObject(ProViewModel())
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

struct ListProPreferencesView: View {
    @EnvironmentObject var viewModel: ProViewModel
    @State private var selectedSection: PreferencesSection = .pro
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
