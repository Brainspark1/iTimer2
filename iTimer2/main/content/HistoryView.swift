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
    @State private var showAlert = false

    @State private var searchQuery: String = ""
    @State private var showSearchBar: Bool = false

    var filteredHistory: [HistoryItem] {
        guard !searchQuery.isEmpty else { return timerManager.history }
        return timerManager.history.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.description.localizedCaseInsensitiveContains(searchQuery) ||
            $0.timestampDescription.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    func highlight(text: String, matching search: String) -> Text {
        guard !search.isEmpty else {
            return Text(text)
        }

        let lowerText = text.lowercased()
        let lowerSearch = search.lowercased()
        
        var result = Text("")
        var currentIndex = text.startIndex

        while let range = lowerText.range(of: lowerSearch, range: currentIndex..<text.endIndex) {
            // Add non-matching part
            let nonMatch = String(text[currentIndex..<range.lowerBound])
            result = result + Text(nonMatch)
            
            // Add matching part with highlight
            let match = String(text[range])
            result = result + Text(match).foregroundColor(.yellow).bold()
            
            // Move index forward
            currentIndex = range.upperBound
        }

        // Add any remaining text
        let remaining = String(text[currentIndex..<text.endIndex])
        result = result + Text(remaining)
        
        return result
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("History")
                .font(.title)
            
            Button(action: {
                showSearchBar.toggle()
            }) {
                EmptyView()
            }
            .keyboardShortcut("s", modifiers: []) // Pressing just "s"
            .opacity(0)
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)

//            Spacer()
            
            if provm.proTrue {
                Button(action: { showPopover.toggle() }) {
                    Image(systemName: "questionmark.circle").font(.title3)
                }
                .popover(isPresented: $showPopover) {
                    Text("Pro Tip 💡 Tap on any previous timer to start a new timer with that preset")
                        .padding()
                }
                .buttonStyle(BorderlessButtonStyle())
            }

            Toggle(isOn: $showTimestamps) {
                Text("Show Timestamps")
            }
            .padding()
            
            if showSearchBar {
                TextField("Search", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            } else {
                Text("Press S to search")
                    .opacity(0.6)
                    .font(.system(size: 12))
            }

            HStack {
                Button(action: {
                    showAlert = true
                }) {
                    Text("Clear History")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .frame(width: 112, height: 26)
                .padding()
                .alert("Confirm", isPresented: $showAlert) {
                    Button("Clear", role: .destructive) {
                        timerManager.clearHistory()
                    }
                    .foregroundColor(.red)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This action cannot be undone.")
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }

            if filteredHistory.isEmpty {
                Text("No results found")
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            } else {
                List(filteredHistory) { historyItem in
                    VStack(alignment: .leading) {
                        let textToDisplay = showTimestamps ? historyItem.timestampDescription : historyItem.description
                        highlight(text: textToDisplay, matching: searchQuery)
                            .onTapGesture {
                                if provm.proTrue {
                                    onSelect(historyItem.hours, historyItem.minutes, historyItem.seconds)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .frame(width: 300, height: 400)
//        .onReceive(NotificationCenter.default.publisher(for: NSEvent.keyDownNotification)) { notification in
//            if let event = notification.object as? NSEvent, event.charactersIgnoringModifiers == "s" {
//                showSearchBar.toggle()
//            }
//        }
//        .alert(isPresented: $timerManager.show75Alert) {
//            Alert(
//                title: Text("Upgrade to Pro"),
//                message: Text("You've reached your history limit of 75 items. Upgrade to Pro to get unlimited entries."),
//                dismissButton: .default(Text("OK"))
//            )
//        }
    }
}
