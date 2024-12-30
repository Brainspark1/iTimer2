//
//  InfoButtons.swift
//  iTimer2
//
//  Created by Nihaal Garud on 07/10/2024.
//

import Foundation
import SwiftUI

struct InfoButtonUp: View {
    @State private var showPopover = false
    var content: String
    
    var body: some View {
        Button(action: {
            showPopover.toggle()
        }) {
            Image(systemName: "questionmark.circle")
                .font(.title3)
        }
        .popover(isPresented: $showPopover, attachmentAnchor: .point(.top), arrowEdge: .top) {
            Text(content)
                .padding()
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct InfoButtonDown: View {
    @State private var showPopover = false
    var content: String
    
    var body: some View {
        Button(action: {
            showPopover.toggle()
        }) {
            Image(systemName: "questionmark.circle")
                .font(.title3)
        }
        .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
            Text(content)
                .padding()
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct InfoButtonLeft: View {
    @State private var showPopover = false
    var content: String
    
    var body: some View {
        Button(action: {
            showPopover.toggle()
        }) {
            Image(systemName: "questionmark.circle")
                .font(.title3)
        }
        .popover(isPresented: $showPopover, attachmentAnchor: .point(.leading), arrowEdge: .leading) {
            Text(content)
                .padding()
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct InfoButtonRight: View {
    @State private var showPopover = false
    var content: String
    
    var body: some View {
        Button(action: {
            showPopover.toggle()
        }) {
            Image(systemName: "questionmark.circle")
                .font(.title3)
        }
        .popover(isPresented: $showPopover, attachmentAnchor: .point(.trailing), arrowEdge: .trailing) {
            Text(content)
                .padding()
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
