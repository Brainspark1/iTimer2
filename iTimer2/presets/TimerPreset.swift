//
//  TimerPreset.swift
//  iTimer2
//
//  Created by Nihaal Garud on 03/07/2025.
//

import Foundation
import SwiftUI

struct TimerPreset: Identifiable, Codable, Hashable {
    let id: UUID
    var hours: Int
    var minutes: Int
    var seconds: Int

    var title: String {
        var parts: [String] = []
        if hours > 0 { parts.append("\(hours) hour\(hours == 1 ? "" : "s")") }
        if minutes > 0 { parts.append("\(minutes) minute\(minutes == 1 ? "" : "s")") }
        if seconds > 0 { parts.append("\(seconds) second\(seconds == 1 ? "" : "s")") }
        return parts.joined(separator: " ")
    }
}

class PresetManager: ObservableObject {
    @AppStorage("customTimerPresets") private var presetData: Data = Data()
    @Published var presets: [TimerPreset] = []

    init() {
        load()
    }

    func load() {
        if let decoded = try? JSONDecoder().decode([TimerPreset].self, from: presetData) {
            presets = decoded
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(presets) {
            presetData = encoded
        }
    }

    func addPreset(hours: Int, minutes: Int, seconds: Int) {
        let newPreset = TimerPreset(id: UUID(), hours: hours, minutes: minutes, seconds: seconds)
        presets.append(newPreset)
        save()
    }

    func removePreset(_ preset: TimerPreset) {
        presets.removeAll { $0.id == preset.id }
        save()
    }
}

struct ManagePresetsSheet: View {
    @ObservedObject var manager: PresetManager
    @Environment(\.dismiss) var dismiss
    @State private var presetToDelete: TimerPreset? = nil
    @State private var showPresetDeleteAlert = false

    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Manage Presets")
                    .font(.title2)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }

            List {
                ForEach(manager.presets) { preset in
                    HStack {
                        Text(preset.title)
                        Spacer()
                        Button(action: {
                            presetToDelete = preset
                            showPresetDeleteAlert = true
                        }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider()

            HStack {
                Stepper("Hours: \(hours)", value: $hours, in: 0...23)
                Stepper("Minutes: \(minutes)", value: $minutes, in: 0...59)
                Stepper("Seconds: \(seconds)", value: $seconds, in: 0...59)
                Spacer()
                Button(action: {
                    manager.addPreset(hours: hours, minutes: minutes, seconds: seconds)
                    hours = 0
                    minutes = 0
                    seconds = 0
                }) {
                    Text("Add")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .fixedSize()
            }
        }
        .padding()
        .frame(width: 400, height: 400)
        .alert("Delete Preset?", isPresented: $showPresetDeleteAlert, presenting: presetToDelete) { preset in
                    Button("Delete", role: .destructive) {
                        manager.removePreset(preset)
                    }
                    Button("Cancel", role: .cancel) { }
                } message: { preset in
                    Text("Are you sure you want to delete the “\(preset.title)” preset?")
                }
    }
}
