//
//  TextFileExporter.swift
//  iTimer2
//
//  Created by Nihaal Garud on 29/06/2025.
//


import AppKit
import Foundation
import SwiftUI

struct TextFileExporter {
    static func export(items: [String]) {
        DispatchQueue.main.async {
            let savePanel = NSSavePanel()
            savePanel.allowedFileTypes = ["txt"]
            savePanel.nameFieldStringValue = "List.txt"
            
            savePanel.begin { response in
                guard response == .OK, let url = savePanel.url else { return }

                let content = items.joined(separator: "\n")
                do {
                    try content.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("Failed to save file: \(error)")
                }
            }
        }
    }
}
