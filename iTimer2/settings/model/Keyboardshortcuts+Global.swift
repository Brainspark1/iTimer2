//
//  Keyboardshortcuts+Global.swift
//  iTimer2
//
//  Created by Nihaal Garud on 11/08/2024.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    
    static let startTimer = Self("startTimer", default: .init(.return, modifiers: .command))
    static let stopTimer = Self("stopTimer", default: .init(.return, modifiers: [.command, .shift]))
    static let openPom = Self("openPom", default: .init(.one, modifiers: .command))
    static let closePom = Self("closePom", default: .init(.one, modifiers: [.command, .shift]))
    static let openStopwatch = Self("openStopwatch", default: .init(.two, modifiers: .command))
    static let closeStopwatch = Self("closeStopwatch", default: .init(.two, modifiers: [.command, .shift]))
    static let history = Self("history", default: .init(.y, modifiers: .command))
    static let popoutTimer = Self("popouTimer", default: .init(.equal, modifiers: .command))
    static let preferences = Self("preferences", default: .init(.comma, modifiers: .command))
    static let quit = Self("quit", default: .init(.q, modifiers: .command))
    static let openApp = Self("openApp", default: .init(.t, modifiers: [.command, .option, .control, .shift]))
    static let onlyTimer = Self("onlyTimer", default: .init(.t, modifiers: [.command, .option, .shift]))
}
