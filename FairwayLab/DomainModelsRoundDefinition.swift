//
//  RoundDefinition.swift
//  GolfX
//
//  Configuration for a golf round (setup before play)
//

import Foundation

struct RoundDefinition: Codable {
    let players: [Player]
    let course: Course
    let tee: Tee
    let holes: [HoleDefinition]
    let selectedGames: Set<GameType>
    let handicapMode: HandicapMode
    let isNineHole: Bool
    let isBackNine: Bool  // Only relevant for 9-hole rounds
    
    init(
        players: [Player],
        course: Course,
        tee: Tee,
        holes: [HoleDefinition],
        selectedGames: Set<GameType>,
        handicapMode: HandicapMode,
        isNineHole: Bool,
        isBackNine: Bool
    ) {
        self.players = players
        self.course = course
        self.tee = tee
        self.holes = holes
        self.selectedGames = selectedGames
        self.handicapMode = handicapMode
        self.isNineHole = isNineHole
        self.isBackNine = isBackNine
    }
    
    var holeCount: Int {
        holes.count
    }
    
    var playedHoleNumbers: [Int] {
        holes.map { $0.actualHoleNumber }
    }
    
    var totalPar: Int {
        holes.map { $0.par }.reduce(0, +)
    }
    
    /// Validate that the round configuration is ready to start
    func validate() -> [String] {
        var errors: [String] = []
        
        // Minimum players
        if players.count < 2 {
            errors.append("At least 2 players are required")
        }
        
        // All players must be valid
        for player in players {
            if !player.isValid {
                errors.append("Player '\(player.name)' has invalid data")
            }
        }
        
        // Holes must be 9 or 18
        if holes.count != 9 && holes.count != 18 {
            errors.append("Round must have 9 or 18 holes")
        }
        
        // Validate stroke index if required by selected games
        let needsValidStrokeIndex = selectedGames.contains { $0.requiresValidStrokeIndex }
        if needsValidStrokeIndex && !isStrokeIndexValid() {
            errors.append("Valid stroke index is required for selected games")
        }
        
        return errors
    }
    
    var isValid: Bool {
        validate().isEmpty
    }
    
    /// Check if stroke index is a valid permutation of 1...holeCount
    func isStrokeIndexValid() -> Bool {
        let indices = holes.map { $0.strokeIndex }
        let expectedSet = Set(1...holes.count)
        let actualSet = Set(indices)
        return expectedSet == actualSet && indices.count == holes.count
    }
}
