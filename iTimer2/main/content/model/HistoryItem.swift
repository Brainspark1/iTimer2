//
//  HistoryItem.swift
//  iTimer2
//
//  Created by Nihaal Garud on 20/06/2025.
//

import Foundation

public struct HistoryItem: Identifiable, Codable, Hashable, Equatable {
    public let id: UUID
    public let name: String
    public let hours: Int
    public let minutes: Int
    public let seconds: Int
    public let timestamp: Date

    public init(id: UUID = UUID(), name: String, hours: Int, minutes: Int, seconds: Int, timestamp: Date = Date()) {
        self.id = id
        self.name = name
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.timestamp = timestamp
    }

    public var description: String {
        return "\(name): \(hours)h \(minutes)m \(seconds)s"
    }

    public var timestampDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return "\(name): \(hours)h \(minutes)m \(seconds)s - \(formatter.string(from: timestamp))"
    }
}
