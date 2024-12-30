//
//  Onboarding.swift
//  iTimer2
//
//  Created by Nihaal Garud on 12/08/2024.
//

import Foundation
import SwiftUI
import LaunchAtLogin

struct Onboard1View: View {
    var body: some View {
        Spacer()
        Text("Welcome to iTimer2")
            .font(.largeTitle)
        Text("Let's get you set up")
            .font(.system(size: 13))
            .opacity(0.5)
            .padding()
        Spacer()
    }
}

struct Onboard2View: View {
    var body: some View {
        Spacer()
        Text("Launch at Login")
            .font(.largeTitle)
        LaunchAtLogin.Toggle("Launch at start")
            .toggleStyle(.switch)
            .padding()
        Text("You can always change this in your Preferences later")
            .font(.system(size: 13))
            .opacity(0.5)
        Spacer()
    }
}

struct Onboard3View: View {
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
            
            Image("iTimer2NewLayout")
                .resizable()
                .frame(width: 190, height: 160)
                .cornerRadius(7)
                .shadow(color: .gray, radius: 5)
                .padding()
        }
        
        Spacer()
    }
}

struct Onboard4View: View {
    var body: some View {
        
        HStack {
            
            Image("pom")
                .resizable()
                .frame(width: 200, height: 200)
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
    
    }
}

struct Onboard5View: View {
    var body: some View {
        
        Spacer()
        
        HStack {
            
            
            VStack {
                
                Spacer()
                Spacer()
                
                Text("History")
                    .font(.largeTitle)
                
                Text("""
                Check history to see what
                you did and to stay on track
                """)
                .font(.system(size: 13))
                .opacity(0.5)
                .frame(width: 195)
                .multilineTextAlignment(.center)
                .padding()
                
                Spacer()
                Spacer()
            }
            
            Image("history")
                .resizable()
                .frame(width: 225, height: 250)
                .cornerRadius(7)
                .shadow(color: .blue, radius: 5)
                .padding()
        }
        
        Spacer()
    }
}

struct Onboard6View: View {
    var body: some View {
        
        HStack {
            
            Image("name")
                .resizable()
                .frame(width: 200, height: 75)
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
    
    }
}

struct Onboard7View: View {
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Text("Keyboard Shortcuts")
                .font(.largeTitle)
            
            Text("""
        iTimer2 has some keyboard shortcuts.
        Customise them in Preferences!
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
            
        }
        
    }
}

struct Onboard8View: View {
    
    @EnvironmentObject var timerManager: TimerManager
    var onFinish: (() -> Void)?
    @State private var showPopover = false
    
    var body: some View {
        
        Spacer()
        
        Text("Info Buttons")
            .font(.largeTitle)
        
        Text("""
    Press the small little question marks
    around the UI for more information!
    """)
        .font(.system(size: 13))
        .opacity(0.5)
        .frame(width: 250)
        .multilineTextAlignment(.center)
        .padding()
        
        Button(action: {
            showPopover.toggle()
        }) {
            Image(systemName: "questionmark.circle")
                .font(.title3)
        }
        .popover(isPresented: $showPopover, attachmentAnchor: .point(.top), arrowEdge: .top) {
            Text("...around the UI to get more info")
                .padding()
        }
        .buttonStyle(BorderlessButtonStyle())
        
        Button(action: {
            timerManager.hasCompletedOnboarding = false
            print("Done")
            onFinish?() // Close the window when button is pressed
        }) {
            Text("Complete Onboarding")
        }
        .shadow(color: .green, radius: 5)
        
        Spacer()
    }
}

struct OnboardingView: View {
    
    var onFinish: (() -> Void)? // Add this property
    
    var body: some View {
        
        CustomTabView(
            content: [
                (
                    title: "Welcome",
                    icon: "hand.wave.fill",
                    view: AnyView(
                        Onboard1View()
                    )
                ),
                (
                    title: "Launch",
                    icon: "arrowshape.up",
                    view: AnyView (
                        Onboard2View()
                    )
                ),
                (
                    title: "Layout",
                    icon: "square.text.square",
                    view: AnyView (
                        Onboard3View()
                    )
                ),
                (
                    title: "Pomodoro",
                    icon: "circle.circle.fill",
                    view: AnyView (
                        Onboard4View()
                    )
                ),
                (
                    title: "History",
                    icon: "list.clipboard.fill",
                    view: AnyView (
                        Onboard5View()
                    )
                ),
                (
                    title: "Names",
                    icon: "pencil",
                    view: AnyView (
                        Onboard6View()
                    )
                ),
                (
                    title: "Keyboard",
                    icon: "keyboard",
                    view: AnyView (
                        Onboard7View()
                    )
                ),
                (
                    title: "Info",
                    icon: "questionmark.circle",
                    view: AnyView(
                        Onboard8View(onFinish: onFinish) // Pass the onFinish closure here
                    )
                )
            ]
        )
    }
}
