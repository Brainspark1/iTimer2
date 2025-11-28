//
//  KeyboardShortcuts_settings.swift
//  iTimer2
//
//  Created by Nihaal Garud on 11/08/2024.
//

import Foundation
import KeyboardShortcuts
import SwiftUI

struct ChooseView: View {
    
    @State private var showPopover = false
    @EnvironmentObject var provm: ProViewModel
    @EnvironmentObject var preferencesvm: PreferencesViewModel
    
    var body: some View {
        
        VStack {
        
        Button(action: {
            showPopover.toggle()
        }) {
            Image(systemName: "questionmark.circle")
                .font(.title3)
        }
        .popover(isPresented: $showPopover) {
            Text("These are global shortcuts, meaning that you can start your timer without being in the app!")
                .padding()
        }
        .buttonStyle(BorderlessButtonStyle())
        .padding(.top, 40)
            
            if !preferencesvm.ifRestarted {
                Text("Please restart iTimer2 to activate these shortcuts")
                    .font(.system(size: 13))
                    .opacity(0.5)
                    .padding()
            }
            
//            Form {
//                KeyboardShortcuts.Recorder("Open iTimer2", name: .openApp)
////              KeyboardShortcuts.Recorder("Toggle Only Timer Mode", name: .onlyTimer)
//            }
//            .padding()
        
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Start/Pause")
                        Spacer()
                        KeyboardShortcuts.Recorder("", name: .startTimer)
                    }
                    HStack {
                        Text("Stop")
                        Spacer()
                        KeyboardShortcuts.Recorder("", name: .stopTimer)
                    }
                    HStack {
                        Text("Open Pomodoro Mode")
                        Spacer()
                        KeyboardShortcuts.Recorder("", name: .openPom)
                    }
                    HStack {
                        Text("Open Stopwatch")
                        Spacer()
                        KeyboardShortcuts.Recorder("", name: .openStopwatch)
                    }
                    HStack {
                        Text("Exit Pomodoro Mode")
                        Spacer()
                        KeyboardShortcuts.Recorder("", name: .closePom)
                    }
                    HStack {
                        Text("Close Stopwatch")
                        Spacer()
                        KeyboardShortcuts.Recorder("", name: .closeStopwatch)
                    }
                    HStack {
                        Text("Show History")
                        Spacer()
                        KeyboardShortcuts.Recorder("", name: .history)
                    }
                    HStack {
                        Text("Popout Timer")
                        Spacer()
                        KeyboardShortcuts.Recorder("", name: .popoutTimer)
                    }
                    HStack {
                        Text("Preferences")
                        Spacer()
                        KeyboardShortcuts.Recorder("", name: .preferences)
                    }
                    HStack {
                        Text("Quit")
                        Spacer()
                        KeyboardShortcuts.Recorder("", name: .quit)
                    }
                    .padding(.bottom, 10)
                }
                .padding()
            }
        }
    }
}
