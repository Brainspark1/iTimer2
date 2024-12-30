//
//  OnboardingModel.swift
//  iTimer2
//
//  Created by Nihaal Garud on 12/08/2024.
//

import Foundation
import SwiftUI

struct Page: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var description: String
    var imageURL: String
    var tag: Int
    
    static var samplePage = Page(name: "iTimer2", description: "Your window to faster workflows", imageURL: "Green Clock Icon 1", tag: 0)
    
    static var pages: [Page] = [
        Page(name: "iTimer2", description: "Your window to faster workflows", imageURL: "Green Clock Icon 1", tag: 0),
        Page(name: "Menu bar", description: "iTimer2 is a menu bar app which can be accessed by pressing the timer icon in your menu bar", imageURL: "menu bar", tag: 1),
        Page(name: "A simple layout", description: "Timer at the top, inputs in the middle and features at the bottom", imageURL: "iTimer2Layout", tag: 2),
        Page(name: "Names", description: "Your timers can now have names, keeping you on track", imageURL: "name", tag: 3),
        Page(name: "Pomodoro Mode", description: "Practice the pomodoro technique with pomodoro mode", imageURL: "pom", tag: 4),
        Page(name: "History", description: "Keep track of your progress with History, including tracking the names and time started, plus utilise the storage as Presets by clicking on the timer to start another with the same time", imageURL: "history", tag: 5),
        Page(name: "Caffeinate", description: "Keep your screen on with caffeinate mode, toggling the little coffee icon on the home page", imageURL: "caffeinate", tag: 6),
        Page(name: "Preferences", description: "Change anything about iTimer2 with the professional preferences page, including timer size and keyboard shortcuts", imageURL: "preferences", tag: 7)
    ]
}
