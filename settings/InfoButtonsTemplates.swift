//
//  InfoButtonsTemplates.swift
//  iTimer2
//
//  Created by Nihaal Garud on 13/08/2024.
//

import Foundation
import SwiftUI

struct LeftQuestionButtonView: View {
    @State private var showPopover = false
    
    var body: some View {
        
                   Button(action: {
                       showPopover.toggle()
                   }) {
                       Image(systemName: "questionmark.circle")
                           .font(.title3)
                   }
                   .popover(isPresented: $showPopover, attachmentAnchor: .point(.leading), arrowEdge: .leading) {
                       Text("___")
                           .padding()
                   }
                   .buttonStyle(BorderlessButtonStyle())
    }
}

struct RightQuestionButtonView: View {
    @State private var showPopover = false
    
    var body: some View {
        
                   Button(action: {
                       showPopover.toggle()
                   }) {
                       Image(systemName: "questionmark.circle")
                           .font(.title3)
                   }
                   .popover(isPresented: $showPopover, attachmentAnchor: .point(.trailing), arrowEdge: .trailing) {
                       Text("___")
                           .padding()
                   }
                   .buttonStyle(BorderlessButtonStyle())
    }
}

struct UpQuestionButtonView: View {
    @State private var showPopover = false
    
    var body: some View {
        
                   Button(action: {
                       showPopover.toggle()
                   }) {
                       Image(systemName: "questionmark.circle")
                           .font(.title3)
                   }
                   .popover(isPresented: $showPopover, attachmentAnchor: .point(.top), arrowEdge: .top) {
                       Text("___")
                           .padding()
                   }
                   .buttonStyle(BorderlessButtonStyle())
    }
}

struct DownQuestionButtonView: View {
    @State private var showPopover = false
    
    var body: some View {
        
                   Button(action: {
                       showPopover.toggle()
                   }) {
                       Image(systemName: "questionmark.circle")
                           .font(.title3)
                   }
                   .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                       Text("___")
                           .padding()
                   }
                   .buttonStyle(BorderlessButtonStyle())
    }
}
