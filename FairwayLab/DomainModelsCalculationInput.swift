//
//  CalculationInput.swift
//  GolfX
//
//  Immutable normalized structure for scoring calculations
//

import Foundation

struct CalculationInput {
    let players: [Player]
    let holes: [HoleDefinition]
    let handicapMode: HandicapMode
    let scores: [UUID: [UUID: Int]]  // playerID -> holeID -> grossStrokes
    let putts: [UUID: [UUID: Int]]   // playerID -> holeID -> putts
    let kpWinners: [UUID: UUID?]     // holeID -> playerID?
    
    struct PlayerHoleScore {
        let player: Player
        let hole: HoleDefinition
        let grossStrokes: Int?
        
        var hasScore: Bool {
            grossStrokes != nil && grossStrokes! > 0
        }
    }
    
    /// Get score for a specific player and hole
    func score(playerID: UUID, holeID: UUID) -> Int? {
        scores[playerID]?[holeID]
    }
    
    /// Get all scores for a player
    func scoresForPlayer(_ playerID: UUID) -> [UUID: Int] {
        scores[playerID] ?? [:]
    }
    
    /// Get KP winner for a hole
    func kpWinner(holeID: UUID) -> UUID? {
        kpWinners[holeID] ?? nil
    }
    
    /// Get putts for a specific player and hole
    func puttCount(playerID: UUID, holeID: UUID) -> Int? {
        putts[playerID]?[holeID]
    }
    
    /// Get all putts for a player
    func puttsForPlayer(_ playerID: UUID) -> [UUID: Int] {
        putts[playerID] ?? [:]
    }
    
    /// Get all player-hole combinations with scores
    func allPlayerHoleScores() -> [PlayerHoleScore] {
        var results: [PlayerHoleScore] = []
        for player in players {
            for hole in holes {
                let score = self.score(playerID: player.id, holeID: hole.id)
                results.append(PlayerHoleScore(player: player, hole: hole, grossStrokes: score))
            }
        }
        return results
    }
}
