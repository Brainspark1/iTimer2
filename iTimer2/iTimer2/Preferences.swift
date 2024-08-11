import Foundation
import SwiftUI
import AppKit
import Cocoa
import ServiceManagement

class TransToggle: ObservableObject {
    
    @State var transApp: Bool = false
}

struct OnaBoardView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        
        VStack {
            
            Image("Green Clock Icon")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            Text("Welcome to iTimer2")
                .font(.title)
            
            TextaCarouselView()
            
        }
    }
}

struct TextaCarouselView: View {
    let items = ["Time anything and everything with the in-built easy-to-use timer.", "Toggle on Pomodoro Mode to enjoy short bursts of break and work.", "Use keyboard shortcuts to help your work...and time...fly by!", "Access a multitude of additional features with the action buttons at the bottom, including caffeination for your Mac and a unique timer history."]

    var body: some View {
        TabView {
            ForEach(0..<items.count, id: \.self) { index in
                TextView(text: items[index])
            }
        }
        .keyboardShortcut(.rightArrow, modifiers: .command)
    }
}

struct TextaView: View {
    let text: String

    var body: some View {
        VStack {
            Text(text)
                .padding()
        }
    }
}

struct GeneralView: View {
    
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    var body: some View {
        
        VStack {
            
            Text("iTimer2")
                .font(.title)
            
            Text("Version: \(getAppVersion())")
                .font(.title3)
                .padding()
            
            Toggle("Launch on start", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { newValue in
                            enableLoginItem(enable: newValue)
                        }
                        .toggleStyle(.switch)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray, lineWidth: 0.5)
                        )
        }
    }
    
    func getAppVersion() -> String {
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                return appVersion
            }
            return "Unknown"
        }
    
    func enableLoginItem(enable: Bool) {
        let helperID = "com.nihaalg.MyAppHelper"
        SMLoginItemSetEnabled(helperID as CFString, enable)
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
                Text("⌘ + P")
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.red)
                Text("Close Pomodoro Mode")
                Text("⌘ + ⇧ + P")
                Spacer()
            }
            .padding()
            
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
            .padding()
            
            Text("Note: Click the Timer to open it out in a Popout view.")
                .font(.subheadline)
            
        }
    }
}

struct TimerView: View {
    @Binding var fontSize: CGFloat
    @AppStorage("workDuration") private var workDuration: String = "25" // Stored in minutes
    @AppStorage("breakDuration") private var breakDuration: String = "5"  // Stored in minutes
    
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
            
            Text("Pomodoro Timer Adjustments:")
                .padding()
                .font(.title2)
            
            HStack {
                
                VStack {
                    Text("Work Duration (min)")
                    TextField("Enter work duration", text: $workDuration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                
                VStack {
                    Text("Break Duration (min)")
                    TextField("Enter break duration", text: $breakDuration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
            }
        }
    }
}
struct PreferencesView: View {
    
    @Binding var fontSize: CGFloat
    
    var body: some View {
        
        CustomTabView(
                content: [
                    (
                        title: "General",
                        icon: "gear.badge",
                        view: AnyView(
                            GeneralView()
                        )
                    ),
                    (
                        title: "Timer",
                        icon: "paintbrush.fill",
                        view: AnyView(
                            TimerView(fontSize: $fontSize)
                        )
                    ),
                    (
                        title: "Keyboard",
                        icon: "keyboard.badge.ellipsis",
                        view: AnyView (
                            KeyView()
                        )
                    ),
                    (
                        title: "Onboarding",
                        icon: "sailboat.fill",
                        view: AnyView (
                            OnaBoardView()
                        )
                    )
                    ]
                )
        
    }
}

