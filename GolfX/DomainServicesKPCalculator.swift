//
//  KPCalculator.swift
//  GolfX
//
//  Service for calculating KP (Closest to Pin) results
//

import Foundation

struct KPResult: Codable {
    let playerWins: [UUID: Int]  // playerID -> number of KP wins
    let holeWinners: [UUID: UUID?]  // holeID -> playerID?
    let eligibleHoles: [HoleDefinition]
    
    func totalWins(for playerID: UUID) -> Int {
        playerWins[playerID] ?? 0
    }
    
    func sortedPlayers(players: [Player]) -> [(Player, Int)] {
        players.map { player in
            (player, totalWins(for: player.id))
        }.sorted { $0.1 > $1.1 }
    }
}

struct KPCalculator {
    
    /// Calculate KP results from manual selections
    static func calculate(input: CalculationInput) -> KPResult {
        // Find all par-3 holes
        let eligibleHoles = input.holes.filter { $0.isPar3 }
        
        var playerWins: [UUID: Int] = [:]
        var holeWinners: [UUID: UUID?] = [:]
        
        for hole in eligibleHoles {
            if let winnerID = input.kpWinner(holeID: hole.id) {
                playerWins[winnerID, default: 0] += 1
                holeWinners[hole.id] = winnerID
            } else {
                holeWinners[hole.id] = nil
            }
        }
        
        return KPResult(
            playerWins: playerWins,
            holeWinners: holeWinners,
            eligibleHoles: eligibleHoles
        )
    }
}
