//
//  Player.swift
//  GolfX
//
//  Domain model for a player in a golf round
//

import Foundation

struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var handicap: Double
    
    init(id: UUID = UUID(), name: String, handicap: Double) {
        self.id = id
        self.name = name
        self.handicap = handicap
    }
    
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }
    
    var isValid: Bool {
        !trimmedName.isEmpty && handicap >= 0 && handicap <= 54
    }
}
