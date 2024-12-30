//
//  ProOnboarding.swift
//  iTimer2
//
//  Created by Nihaal Garud on 15/08/2024
//

import Foundation
import SwiftUI

struct ProOnboarding1View: View {
    @Binding var selectedTab: Int
    var body: some View {
        Spacer()
        Text("New Pro Features")
            .font(.largeTitle)
        Text("Let's see what's new")
            .font(.system(size: 13))
            .opacity(0.5)
            .padding()
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

struct ProOnboarding2View: View {
    @Binding var selectedTab: Int
    var body: some View {
        Spacer()
        
        HStack {
            
            VStack {
                
                Spacer()
                
                Text("History Presets")
                    .font(.largeTitle)
                    .padding()
                
                Text("""
                Click on a timer in history to start
                another with the same time
                """)
                .font(.system(size: 13))
                .opacity(0.5)
                .frame(width: 250)
                .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            Image("prohistory")
                .resizable()
                .frame(width: 175, height: 185)
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

struct ProOnboarding6View: View {
    @Binding var selectedTab: Int
    var body: some View {
        Spacer()
        
        HStack {
            
            VStack {
                
                Spacer()
                
                Text("Timer Presets")
                    .font(.largeTitle)
                    .padding()
                
                Text("""
                Right-click the start timer button
                to open a list of curated presets
                """)
                .font(.system(size: 13))
                .opacity(0.5)
                .frame(width: 250)
                .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            Image("propresets")
                .resizable()
                .frame(width: 195, height: 185)
                .cornerRadius(7)
                .shadow(color: .purple, radius: 5)
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

struct ProOnboarding3View: View {
    @Binding var selectedTab: Int
    var body: some View {
        
        Spacer()
        
        HStack {
            
            Image("prokeys")
                .resizable()
                .frame(width: 240, height: 200)
                .cornerRadius(7)
                .shadow(color: .gray, radius: 5)
                .padding()
            
            VStack {
                
                Text("Keyboard Shortcuts")
                    .font(.largeTitle)
                    .padding()
                
                Text("""
                You can now customise your own
                keyboard shortcuts in Preferences!
                """)
                .font(.system(size: 13))
                .opacity(0.5)
                .frame(width: 250)
                .multilineTextAlignment(.center)
                
                Text("""
                Note: Please restart iTimer2
                to activate these shortcuts.
                """)
                .font(.system(size: 13))
                .opacity(0.5)
                .frame(width: 250)
                .multilineTextAlignment(.center)
                .padding()
                
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

struct ProOnboarding4View: View {
    @Binding var selectedTab: Int
    var body: some View {
        Spacer()
        
        HStack {
            
            VStack {
                
                Spacer()
                
                Text("Progress Bar")
                    .font(.largeTitle)
                    .padding()
                
                Text("""
                Use progress bars in popout mode to
                clearly see how much time is left!
                """)
                .font(.system(size: 13))
                .opacity(0.5)
                .frame(width: 250)
                .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            Image("proprogress")
                .resizable()
                .frame(width: 220, height: 185)
                .cornerRadius(7)
                .shadow(color: .green, radius: 5)
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

struct ProOnboarding5View: View {
    @Binding var selectedTab: Int
    var body: some View {
        
        Spacer()
        
        HStack {
            
            Image("proalarm")
                .resizable()
                .frame(width: 240, height: 200)
                .cornerRadius(7)
                .shadow(color: .yellow, radius: 5)
                .padding()
            
            VStack {
                
                Text("Sounds")
                    .font(.largeTitle)
                    .padding()
                
                Text("""
                You can now customise
                alarm sounds
                when the timer finishes in Preferences.
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
        }
    }
}

//struct ProOnboardingView: View {
//    var body: some View {
//        CustomTabView(
//            content: [
//                (
//                    title: "Welcome",
//                    icon: "hand.wave.fill",
//                    view: AnyView(
//                        ProOnboarding1View()
//                    )
//                ),
//                (
//                    title: "Presets",
//                    icon: "puzzlepiece.extension",
//                    view: AnyView(
//                        ProOnboarding2View()
//                    )
//                ),
//                (
//                    title: "Keyboard",
//                    icon: "keyboard.badge.ellipsis",
//                    view: AnyView (
//                        ProOnboarding3View()
//                    )
//                ),
//                (
//                    title: "Progress",
//                    icon: "line.3.horizontal",
//                    view: AnyView (
//                        ProOnboarding4View()
//                    )
//                ),
//                (
//                    title: "Sounds",
//                    icon: "speaker.wave.3",
//                    view: AnyView (
//                        ProOnboarding5View()
//                    )
//                )
//            ]
//        )
//
//    }
//}

struct NewProOnboardingView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if selectedTab == 0 {
                ProOnboarding1View(selectedTab: $selectedTab)
            } else if selectedTab == 1 {
                ProOnboarding2View(selectedTab: $selectedTab)
            } else if selectedTab == 2 {
                ProOnboarding3View(selectedTab: $selectedTab)
            } else if selectedTab == 3 {
                ProOnboarding6View(selectedTab: $selectedTab)
            } else if selectedTab == 4 {
                ProOnboarding4View(selectedTab: $selectedTab)
            } else if selectedTab == 5 {
                ProOnboarding5View(selectedTab: $selectedTab)
            }
        }
    }
}
//
//#Preview {
//    NewProOnboardingView()
//        .frame(width: 1000, height: 100)
//}
