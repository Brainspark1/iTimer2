//
//  ContentViewModifier.swift
//  iTimer2
//
//  Created by Nihaal Garud on 16/08/2024.
//

import Foundation
import SwiftUI

struct ConditionalKeyboardShortcutModifier: ViewModifier {
    var isShortcutEnabled: Bool
    var shortcut: KeyboardShortcut?
    
    func body(content: Content) -> some View {
        if isShortcutEnabled, let shortcut = shortcut {
            content.keyboardShortcut(shortcut)
        } else {
            content // No shortcut is applied
        }
    }
}

    extension View {
        func conditionalKeyboardShortcut(isEnabled: Bool, _ shortcut: KeyboardShortcut?) -> some View {
            self.modifier(ConditionalKeyboardShortcutModifier(isShortcutEnabled: isEnabled, shortcut: shortcut))
        }
    }
