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
            
            if !preferencesvm.ifRestarted {
                Text("Please restart iTimer2 to activate these shortcuts")
                    .font(.system(size: 13))
                    .opacity(0.5)
                    .padding()
            }
            
            Form {
                KeyboardShortcuts.Recorder("Open iTimer2", name: .openApp)
//              KeyboardShortcuts.Recorder("Toggle Only Timer Mode", name: .onlyTimer)
            }
            .padding()
        
            HStack {
                
                Form {
                    KeyboardShortcuts.Recorder("Start/Pause", name: .startTimer)
                    KeyboardShortcuts.Recorder("Stop", name: .stopTimer)
                    KeyboardShortcuts.Recorder("Open Pomodoro Mode", name: .openPom)
                    KeyboardShortcuts.Recorder("Open Stopwatch", name: .openStopwatch)
                    KeyboardShortcuts.Recorder("Exit Pomodoro Mode", name: .closePom)
                }
                .padding()
                
                Form {
                    KeyboardShortcuts.Recorder("Close Stopwatch", name: .closeStopwatch)
                    KeyboardShortcuts.Recorder("Show History", name: .history)
                    KeyboardShortcuts.Recorder("Popout Timer", name: .popoutTimer)
                    KeyboardShortcuts.Recorder("Preferences", name: .preferences)
                    KeyboardShortcuts.Recorder("Quit", name: .quit)
                }
                .padding()
                
                Spacer()
            }
        }
    }
}
