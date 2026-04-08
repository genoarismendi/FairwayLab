//
//  CaraEPerroCalculator.swift
//  GolfX
//
//  Service for calculating Cara 'e Perro results
//
//  Cara 'e Perro is a pairwise comparison game where each player competes
//  against every other player on each hole. Points are awarded based on
//  head-to-head comparisons with handicap adjustments.
//

import Foundation

struct CaraEPerroHoleResult: Codable {
    let hole: HoleDefinition
    let playerGrossScores: [UUID: Int]
    let playerHolePoints: [UUID: Int]  // Points earned on this hole (can be negative)
    let playerCumulativePoints: [UUID: Int]  // Running total up to and including this hole
}

struct CaraEPerroResult: Codable {
    let playerCumulativePoints: [UUID: Int]  // Final cumulative points
    let holeResults: [CaraEPerroHoleResult]
    let playerHandicapIndices: [UUID: Int]  // Original handicap indices
    
    func totalPoints(for playerID: UUID) -> Int {
        playerCumulativePoints[playerID] ?? 0
    }
    
    func sortedPlayers(players: [Player]) -> [(Player, Int)] {
        players.map { player in
            (player, totalPoints(for: player.id))
        }.sorted { $0.1 > $1.1 }
    }
}

struct CaraEPerroCalculator {
    
    /// Calculate Cara 'e Perro results using pairwise comparison algorithm
    static func calculate(
        input: CalculationInput,
        tee: Tee
    ) -> CaraEPerroResult {
        // Get handicap indices (rounded to nearest integer)
        let handicapIndices = input.players.reduce(into: [UUID: Int]()) { result, player in
            result[player.id] = Int(round(player.handicap))
        }
        
        // Precompute handicap deltas for all pairs
        let handicapDeltas = computeHandicapDeltas(players: input.players, handicapIndices: handicapIndices)
        
        var holeResults: [CaraEPerroHoleResult] = []
        var cumulativePoints: [UUID: Int] = input.players.reduce(into: [:]) { $0[$1.id] = 0 }
        
        // Process each hole
        for hole in input.holes.sorted(by: { $0.displayOrder < $1.displayOrder }) {
            let holePoints = calculateHolePoints(
                hole: hole,
                players: input.players,
                input: input,
                handicapIndices: handicapIndices,
                handicapDeltas: handicapDeltas
            )
            
            // Update cumulative points
            for playerID in holePoints.keys {
                cumulativePoints[playerID, default: 0] += holePoints[playerID] ?? 0
            }
            
            // Get gross scores for this hole
            var grossScores: [UUID: Int] = [:]
            for player in input.players {
                if let score = input.score(playerID: player.id, holeID: hole.id), score > 0 {
                    grossScores[player.id] = score
                }
            }
            
            holeResults.append(CaraEPerroHoleResult(
                hole: hole,
                playerGrossScores: grossScores,
                playerHolePoints: holePoints,
                playerCumulativePoints: cumulativePoints
            ))
        }
        
        return CaraEPerroResult(
            playerCumulativePoints: cumulativePoints,
            holeResults: holeResults,
            playerHandicapIndices: handicapIndices
        )
    }
    
    /// Compute handicap deltas for all unique pairs
    private static func computeHandicapDeltas(
        players: [Player],
        handicapIndices: [UUID: Int]
    ) -> [String: Int] {
        var deltas: [String: Int] = [:]
        
        for i in 0..<players.count {
            for j in (i+1)..<players.count {
                let player1 = players[i]
                let player2 = players[j]
                let hcp1 = handicapIndices[player1.id] ?? 0
                let hcp2 = handicapIndices[player2.id] ?? 0
                let delta = abs(hcp1 - hcp2)
                
                // Store both orderings for easy lookup
                deltas[pairKey(player1.id, player2.id)] = delta
                deltas[pairKey(player2.id, player1.id)] = delta
            }
        }
        
        return deltas
    }
    
    /// Calculate points for all players on a given hole using pairwise comparison
    private static func calculateHolePoints(
        hole: HoleDefinition,
        players: [Player],
        input: CalculationInput,
        handicapIndices: [UUID: Int],
        handicapDeltas: [String: Int]
    ) -> [UUID: Int] {
        var points: [UUID: Int] = players.reduce(into: [:]) { $0[$1.id] = 0 }
        
        let strokeIndex = hole.strokeIndex
        
        // Compare all unique pairs
        for i in 0..<players.count {
            for j in (i+1)..<players.count {
                let player1 = players[i]
                let player2 = players[j]
                
                // Get gross strokes for both players
                guard let strokes1 = input.score(playerID: player1.id, holeID: hole.id),
                      let strokes2 = input.score(playerID: player2.id, holeID: hole.id),
                      strokes1 > 0, strokes2 > 0 else {
                    continue  // Skip if either player doesn't have a valid score
                }
                
                let hcp1 = handicapIndices[player1.id] ?? 0
                let hcp2 = handicapIndices[player2.id] ?? 0
                let delta = handicapDeltas[pairKey(player1.id, player2.id)] ?? 0
                
                // Apply handicap stroke adjustment
                var adjustedStrokes1 = strokes1
                var adjustedStrokes2 = strokes2
                
                if delta >= strokeIndex {
                    // The player with the LOWER handicap receives +1 stroke
                    if hcp1 < hcp2 {
                        adjustedStrokes1 += 1
                    } else if hcp2 < hcp1 {
                        adjustedStrokes2 += 1
                    }
                    // If equal handicaps, no adjustment (though delta would be 0)
                }
                
                // Compare adjusted strokes
                if adjustedStrokes1 < adjustedStrokes2 {
                    points[player1.id, default: 0] += 1
                    points[player2.id, default: 0] -= 1
                } else if adjustedStrokes1 > adjustedStrokes2 {
                    points[player1.id, default: 0] -= 1
                    points[player2.id, default: 0] += 1
                }
                // If equal, no points awarded
            }
        }
        
        return points
    }
    
    /// Create a unique key for a pair of players
    private static func pairKey(_ player1: UUID, _ player2: UUID) -> String {
        "\(player1.uuidString)-\(player2.uuidString)"
    }
}
