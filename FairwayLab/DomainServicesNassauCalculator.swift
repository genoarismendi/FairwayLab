//
//  NassauCalculator.swift
//  GolfX
//
//  Service for calculating Nassau results
//

import Foundation

struct NassauResult: Codable {
    let playerPoints: [UUID: Int]  // playerID -> total Nassau points (0-3)
    let frontWinner: UUID?
    let backWinner: UUID?
    let totalWinner: UUID?
    let frontScores: [UUID: Int]
    let backScores: [UUID: Int]
    let totalScores: [UUID: Int]
    
    func totalPoints(for playerID: UUID) -> Int {
        playerPoints[playerID] ?? 0
    }
    
    func sortedPlayers(players: [Player]) -> [(Player, Int)] {
        players.map { player in
            (player, totalPoints(for: player.id))
        }.sorted { $0.1 > $1.1 }
    }
}

struct NassauCalculator {
    
    /// Calculate Nassau results (only for 18-hole rounds)
    static func calculate(
        input: CalculationInput,
        tee: Tee
    ) -> NassauResult? {
        // Nassau requires 18 holes
        guard input.holes.count == 18 else {
            return nil
        }
        
        // Calculate playing handicaps
        let playingHandicaps = HandicapCalculator.calculatePlayingHandicaps(
            players: input.players,
            slope: tee.slope,
            courseRating: tee.courseRating,
            par: input.holes.map { $0.par }.reduce(0, +),
            mode: input.handicapMode
        )
        
        // Calculate strokes per hole for each player
        var allStrokesPerHole: [UUID: [UUID: Int]] = [:]
        for player in input.players {
            let playingHandicap = playingHandicaps[player.id] ?? 0
            allStrokesPerHole[player.id] = HandicapCalculator.strokesPerHole(
                playingHandicap: playingHandicap,
                holes: input.holes
            )
        }
        
        // Separate front and back nine
        let frontHoles = input.holes.filter { $0.actualHoleNumber <= 9 }
        let backHoles = input.holes.filter { $0.actualHoleNumber > 9 }
        
        var frontScores: [UUID: Int] = [:]
        var backScores: [UUID: Int] = [:]
        var totalScores: [UUID: Int] = [:]
        
        // Calculate scores for each segment
        for player in input.players {
            var frontTotal = 0
            var backTotal = 0
            
            for hole in frontHoles {
                if let gross = input.score(playerID: player.id, holeID: hole.id), gross > 0 {
                    let strokes = allStrokesPerHole[player.id]?[hole.id] ?? 0
                    frontTotal += (gross - strokes)
                }
            }
            
            for hole in backHoles {
                if let gross = input.score(playerID: player.id, holeID: hole.id), gross > 0 {
                    let strokes = allStrokesPerHole[player.id]?[hole.id] ?? 0
                    backTotal += (gross - strokes)
                }
            }
            
            frontScores[player.id] = frontTotal
            backScores[player.id] = backTotal
            totalScores[player.id] = frontTotal + backTotal
        }
        
        // Determine winners for each segment
        let frontWinner = determineWinner(scores: frontScores)
        let backWinner = determineWinner(scores: backScores)
        let totalWinner = determineWinner(scores: totalScores)
        
        // Calculate points (1 per segment won)
        var playerPoints: [UUID: Int] = [:]
        for player in input.players {
            var points = 0
            if frontWinner == player.id { points += 1 }
            if backWinner == player.id { points += 1 }
            if totalWinner == player.id { points += 1 }
            playerPoints[player.id] = points
        }
        
        return NassauResult(
            playerPoints: playerPoints,
            frontWinner: frontWinner,
            backWinner: backWinner,
            totalWinner: totalWinner,
            frontScores: frontScores,
            backScores: backScores,
            totalScores: totalScores
        )
    }
    
    private static func determineWinner(scores: [UUID: Int]) -> UUID? {
        guard !scores.isEmpty else { return nil }
        
        let validScores = scores.filter { $0.value > 0 }
        guard !validScores.isEmpty else { return nil }
        
        let minScore = validScores.values.min()!
        let winners = validScores.filter { $0.value == minScore }
        
        // Only return winner if there's no tie
        return winners.count == 1 ? winners.first?.key : nil
    }
}
