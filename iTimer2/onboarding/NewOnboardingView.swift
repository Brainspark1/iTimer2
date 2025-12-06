//
//  NewOnboardingView.swift
//  iTimer2
//
//  Created by Nihaal Garud on 19/08/2024.
//

import Foundation
import SwiftUI
import LaunchAtLogin
import UserNotifications

struct NewOnboardingView: View {
    @State private var selectedTab = 0
    var onFinish: (() -> Void)
    
    var body: some View {
        Group {
            if selectedTab == 0 {
                NewOnboard1View(selectedTab: $selectedTab)
            } else if selectedTab == 1 {
                NewOnboard2View(selectedTab: $selectedTab)
                    .environmentObject(TimerManager(provm: ProViewModel(), analyticsvm: AnalyticsViewModel()))
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
                NewOnboard10View(selectedTab: $selectedTab, onFinish: onFinish)
            }
        }
    }
}

struct NewOnboard1View: View {
    @Binding var selectedTab: Int
    var body: some View {
        Spacer()
        Spacer()
        Spacer(minLength: 20)
        Text("Welcome to iTimer2")
            .font(.largeTitle)
        Text("Let's get you set up")
            .font(.system(size: 13))
            .opacity(0.5)
            .padding()
        Spacer()
        Spacer()
        Button(action: {
            selectedTab += 1
        }) {
            Image(systemName: "arrow.right.circle")
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle())
        .font(.title2)
    }
}

struct NewOnboard2View: View {
    let un = UNUserNotificationCenter.current()
    @Binding var selectedTab: Int
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        Spacer()
        Spacer()
        Text("Quick Settings")
            .font(.largeTitle)
        LaunchAtLogin.Toggle("Launch at start")
            .toggleStyle(.switch)
            .padding(.top, 25)
        
        Toggle("Notifications", isOn: $timerManager.notificationsEnabled)
            .toggleStyle(.switch)
            .padding()
            .onChange(of: timerManager.notificationsEnabled) {
                if timerManager.notificationsEnabled {
                    notifyUserPermissions()
                }
            }
            .padding()
        
        Text("You can always change these in your Preferences later")
            .font(.system(size: 13))
            .opacity(0.5)
        Spacer()
        HStack {
            Button(action: {
                selectedTab -= 1
            }) {
                Image(systemName: "arrow.left.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
            
            Button(action: {
                selectedTab += 1
            }) {
                Image(systemName: "arrow.right.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
        }
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

struct NewOnboard3View: View {
    @Binding var selectedTab: Int
    var body: some View {
        
        Spacer()
        
        HStack {
            
            VStack {
                
                Spacer()
                
                Text("Menu Bar Layout")
                    .font(.largeTitle)
                    .padding()
                
                Text("""
                iTimer2 has a very simple menu
                bar layout, containing only
                text and buttons!
                """)
                .font(.system(size: 13))
                .opacity(0.5)
                .frame(width: 250)
                .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            Image("newMenubar")
                .resizable()
                .frame(width: 190, height: 215)
                .cornerRadius(7)
                .shadow(color: .gray, radius: 5)
                .padding()
        }
        
        Spacer()
        HStack {
            Button(action: {
                selectedTab -= 1
            }) {
                Image(systemName: "arrow.left.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
            
            Button(action: {
                selectedTab += 1
            }) {
                Image(systemName: "arrow.right.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
        }
    }
}

struct NewOnboard4View: View {
    @Binding var selectedTab: Int
    var body: some View {
        
        Spacer()
        
        HStack {
            
            Image("newPom")
                .resizable()
                .frame(width: 200, height: 225)
                .cornerRadius(7)
                .shadow(color: .red, radius: 5)
                .padding()
            
            VStack {
                
                Text("Pomodoro Mode")
                    .font(.largeTitle)
                    .padding()
                
                Text("""
                Practice the Pomodoro technique
                with Pomodoro Mode
                """)
                .font(.system(size: 13))
                .opacity(0.5)
                .frame(width: 250)
                .multilineTextAlignment(.center)
                
            }
        }
        Spacer()
        HStack {
            Button(action: {
                selectedTab -= 1
            }) {
                Image(systemName: "arrow.left.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
            
            Button(action: {
                selectedTab += 1
            }) {
                Image(systemName: "arrow.right.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
        }
    }
}

struct NewOnboard5View: View {
    @Binding var selectedTab: Int
    var body: some View {
        
        Spacer()
        
        HStack {
            
            
            VStack {
                
                Spacer()
                Spacer()
                
                Text("History")
                    .font(.largeTitle)
                
                Text("""
                Check and search through history 
                to see what you did and to stay 
                on track
                """)
                .font(.system(size: 13))
                .opacity(0.5)
                .frame(width: 195)
                .multilineTextAlignment(.center)
                .padding()
                
                Spacer()
                Spacer()
            }
            
            Image("newHistory")
                .resizable()
                .frame(width: 225, height: 280)
                .cornerRadius(7)
                .shadow(color: .blue, radius: 5)
                .padding()
        }
        
        Spacer()
        HStack {
            Button(action: {
                selectedTab -= 1
            }) {
                Image(systemName: "arrow.left.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
            
            Button(action: {
                selectedTab += 1
            }) {
                Image(systemName: "arrow.right.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
        }
    }
}

struct NewOnboard6View: View {
    @Binding var selectedTab: Int
    var body: some View {
        
        Spacer()
        
        HStack {
            
            Image("newName")
                .resizable()
                .frame(width: 245, height: 75)
                .cornerRadius(7)
                .shadow(color: .yellow, radius: 5)
                .padding()
            
            VStack {
                
                Text("Naming")
                    .font(.largeTitle)
                    .padding()
                
                Text("""
                Name your timers, and see the
                names appear in the menu bar!
                """)
                .font(.system(size: 13))
                .opacity(0.5)
                .frame(width: 250)
                .multilineTextAlignment(.center)
                
            }
        }
        
        Spacer()
        
        HStack {
            Button(action: {
                selectedTab -= 1
            }) {
                Image(systemName: "arrow.left.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
            
            Button(action: {
                selectedTab += 1
            }) {
                Image(systemName: "arrow.right.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
        }
    
    }
}

struct NewOnboard7View: View {
    @Binding var selectedTab: Int
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Text("Keyboard Shortcuts")
                .font(.largeTitle)
            
            Text("""
        iTimer2 has some keyboard shortcuts.
        Customise them in Preferences with Pro!
        """)
            .font(.system(size: 13))
            .opacity(0.5)
            .frame(width: 250)
            .multilineTextAlignment(.center)
            .padding()
            
            HStack {
                
                Spacer()
                
                Text("Start Timer")
                    .font(.title3)
                
                Spacer()
                
                Image(systemName: "command")
                    .font(.title)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 0.5))
                            .frame(width: 35, height: 35)
                    )
                Image(systemName: "return")
                    .font(.title)
                    .padding([.leading, .trailing], 15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 0.5))
                            .frame(width: 35, height: 35)
                    )
                
                Spacer()
            }
            .padding()
            
            HStack {
                
                Spacer()
                
                Text("Popout Timer")
                    .font(.title3)
                
                Spacer()
                
                Image(systemName: "command")
                    .font(.title)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 0.5))
                            .frame(width: 35, height: 35)
                    )
                Image(systemName: "equal")
                    .font(.system(size: 29))
                    .padding([.leading, .trailing], 19)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 0.5))
                            .frame(width: 35, height: 35)
                    )
                
                Spacer()
            }
            .padding()
            
            Spacer()
            HStack {
                Button(action: {
                    selectedTab -= 1
                }) {
                    Image(systemName: "arrow.left.circle")
                }
                .padding()
                .buttonStyle(BorderlessButtonStyle())
                .font(.title2)
                
                Button(action: {
                    selectedTab += 1
                }) {
                    Image(systemName: "arrow.right.circle")
                }
                .padding()
                .buttonStyle(BorderlessButtonStyle())
                .font(.title2)
            }
            
        }
        
    }
}

struct NewOnboard8View: View {
    
    @EnvironmentObject var provm: ProViewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        
        Spacer()
        
        Text("Buy iTimer2 Pro")
            .font(.largeTitle)
            .padding()
        
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
                Text("History Presets")
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
                Text("Customisable Alarm Sounds")
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
        
        Text("$2.99")
            .font(.title2)
            .opacity(0.5)
            .padding()
        
//        Button("Go Pro") {
//            
//            provm.proTrue = true
//            selectedTab += 1
//            openProOnboarding()
//            UserDefaults.standard.set(true, forKey: "proModeTrueBool")
//            
//        }
//        .shadow(color: .green, radius: 5)
        
        Text("You can choose to go Pro later in preferences")
        
        Spacer()
        
//        Button("Continue", action: { selectedTab += 1 })
//            .padding()
//            .buttonStyle(BorderlessButtonStyle())
//
//        Spacer()
        
        HStack {
            Button(action: {
                selectedTab -= 1
            }) {
                Image(systemName: "arrow.left.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
            
            Button(action: {
                selectedTab += 1
            }) {
                Image(systemName: "arrow.right.circle")
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
        }
    }
    
//    func openProOnboarding() {
//        let newWindow = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 750, height: 450),
//            styleMask: [.titled, .closable, .resizable, .miniaturizable],
//            backing: .buffered, defer: false)
//        let onboardIdentifier = NSUserInterfaceItemIdentifier("proonboarding")
//        
//        newWindow.center()
//        newWindow.title = "Pro Onboarding Screen"
//        newWindow.identifier = onboardIdentifier
//        newWindow.isReleasedWhenClosed = false
//        
//        let onboardingView = NewProOnboardingView()
//            .frame(width: 750, height: 425)
//        
//        newWindow.contentView = NSHostingView(rootView: onboardingView.environmentObject(TimerManager()))
//        newWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
//        newWindow.standardWindowButton(.zoomButton)?.isHidden = true
//        
//        //hide title and bar
//        newWindow.titleVisibility = .hidden
//        newWindow.makeKeyAndOrderFront(nil)
//        newWindow.orderFrontRegardless()
//    }
}

//struct NewOnboard9View: View {
//    @Binding var selectedTab: Int
//    
//    var body: some View {
//        
//        VStack {
//            
//            Spacer()
//            
//            Text("iTimer2 Updates Newsletter")
//                .font(.largeTitle)
//                .padding()
//            
//            Text("""
//    Join the iTimer2 App Updates email newsletter at https://itimer2updates.substack.com, allowing us to easily send you new updates of iTimer2 straight to your inbox.
//    """)
//            .font(.system(size: 13))
//            .opacity(0.5)
//            .frame(width: 250)
//            .multilineTextAlignment(.center)
//            .padding()
//            
//            Spacer()
//            
//            HStack {
//                Button(action: {
//                    selectedTab -= 1
//                }) {
//                    Image(systemName: "arrow.left.circle")
//                }
//                .padding()
//                .buttonStyle(BorderlessButtonStyle())
//                .font(.title2)
//                
//                Button(action: {
//                    selectedTab += 1
//                }) {
//                    Image(systemName: "arrow.right.circle")
//                }
//                .padding()
//                .buttonStyle(BorderlessButtonStyle())
//                .font(.title2)
//            }
//        }
//    }
//}

struct NewOnboard10View: View {
    
    @Binding var selectedTab: Int
    @EnvironmentObject var timerManager: TimerManager
    var onFinish: (() -> Void)?
    @State private var showPopover = false
    
    var body: some View {
        
        Spacer()
        
        HStack {
            Text("Info Buttons")
                .font(.largeTitle)
                .padding()
            
            Image(systemName: "questionmark.circle")
                .font(.title2)
        }
        
        Text("""
    Press the small little question marks
    around the UI for more information!
    """)
        .font(.system(size: 13))
        .opacity(0.5)
        .frame(width: 250)
        .multilineTextAlignment(.center)
        .padding([.top, .leading, .trailing])
        
        Text("""
            Join the iTimer2 App Updates email newsletter at https://itimer2updates.substack.com, allowing us to easily send you new updates of iTimer2 straight to your inbox.
            """)
            .font(.system(size: 13))
            .opacity(0.5)
            .frame(width: 250)
            .multilineTextAlignment(.center)
            .padding()

        Spacer()
        
        Button(action: {
            timerManager.hasCompletedOnboarding = false
            print("Done")
            onFinish?() // Close the window when button is pressed
        }) {
            Text("Complete Onboarding")
        }
        .shadow(color: .green, radius: 5)
        
        Spacer()
        Spacer()
        
        Button(action: {
            selectedTab -= 1
        }) {
            Image(systemName: "arrow.left.circle")
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle())
        .font(.title2)
    }
}
