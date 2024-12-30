//
//  HistoryView.swift
//  iTimer2
//
//  Created by Nihaal Garud on 17/08/2024.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var provm: ProViewModel
    @State var showTimestamps: Bool = false
    var onSelect: (Int, Int, Int) -> Void
    @State private var showPopover = false

    var body: some View {
        VStack {
            Spacer()
            Text("History")
                .font(.title)
            Spacer()
            
            if provm.proTrue == true {
                
                Button(action: {
                    showPopover.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.title3)
                }
                .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    Text("Pro Tip 💡 Tap on any previous timer to start a new timer with that preset")
                        .padding()
                }
                .buttonStyle(BorderlessButtonStyle())
                
            }
             
            Toggle(isOn: $showTimestamps) {
                Text("Show Timestamps")
            }
            .padding()

            HStack {
                Button("Clear History") {
                    timerManager.clearHistory()  // Call the method to clear history
                }
                .foregroundColor(.red)
                .padding()
                .fixedSize()

                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .fixedSize()
            }
            .padding()

            List(timerManager.history) { historyItem in
                VStack(alignment: .leading) {
                    Text(showTimestamps ? historyItem.timestampDescription : historyItem.description)
                        .onTapGesture {
                            if provm.proTrue == true {
                                onSelect(historyItem.hours, historyItem.minutes, historyItem.seconds)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                }
            }

            Spacer()
        }
        .padding()
        .frame(width: 300, height: 400)
    }
}
