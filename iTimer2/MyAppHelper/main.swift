//
//  main.swift
//  MyAppHelper
//
//  Created by Nihaal Garud on 21/07/2024.
//

import Foundation
import Cocoa

let mainAppIdentifier = "com.nihaalg.iTimer2"

if let bundleIdentifier = Bundle.main.bundleIdentifier {
    print("Main App Bundle Identifier: \(bundleIdentifier)")
} else {
    print("Failed to retrieve the bundle identifier.")
}

for app in NSWorkspace.shared.runningApplications {
    if app.bundleIdentifier == mainAppIdentifier {
        // The main app is already running, exit the helper
        exit(0)
    }
}

// Launch the main app
let path = Bundle.main.bundlePath as NSString
var components = path.pathComponents
components.removeLast(3)
components.append(contentsOf: ["MacOS", "iTimer2"])
let newPath = NSString.path(withComponents: components)

NSWorkspace.shared.launchApplication(newPath)
