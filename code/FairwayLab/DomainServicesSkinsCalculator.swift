//
//  SkinsCalculator.swift
//  GolfX
//
//  Service for calculating Skins
//

import Foundation

struct SkinsResult: Codable {
    let playerSkins: [UUID: Int]  // playerID -> total skins won
    let holeWinners: [UUID: UUID?]  // holeID -> playerID? (nil if tied)
    let holeValues: [UUID: Int]  // holeID -> skin value (with carry)
    
    func totalSkins(for playerID: UUID) -> Int {
        playerSkins[playerID] ?? 0
    }
    
    func sortedPlayers(players: [Player]) -> [(Player, Int)] {
        players.map { player in
            (player, totalSkins(for: player.id))
        }.sorted { $0.1 > $1.1 }
    }
}

struct SkinsCalculator {
    
    /// Calculate Skins results with carry
    static func calculate(
        input: CalculationInput,
        tee: Tee,
        useNet: Bool,
        withCarry: Bool
    ) -> SkinsResult {
        var playerSkins: [UUID: Int] = [:]
        var holeWinners: [UUID: UUID?] = [:]
        var holeValues: [UUID: Int] = [:]
        
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
        
        var carriedValue = 1  // Start with 1 skin per hole
        
        for hole in input.holes.sorted(by: { $0.displayOrder < $1.displayOrder }) {
            // Collect scores for this hole
            var holeScores: [(UUID, Int)] = []
            
            for player in input.players {
                guard let grossScore = input.score(playerID: player.id, holeID: hole.id),
                      grossScore > 0 else {
                    continue
                }
                
                let finalScore: Int
                if useNet {
                    let strokes = allStrokesPerHole[player.id]?[hole.id] ?? 0
                    finalScore = grossScore - strokes
                } else {
                    finalScore = grossScore
                }
                
                holeScores.append((player.id, finalScore))
            }
            
            // Find best score
            guard !holeScores.isEmpty else {
                holeValues[hole.id] = carriedValue
                holeWinners[hole.id] = nil
                if withCarry {
                    carriedValue += 1
                }
                continue
            }
            
            let bestScore = holeScores.map { $0.1 }.min()!
            let winners = holeScores.filter { $0.1 == bestScore }
            
            holeValues[hole.id] = carriedValue
            
            if winners.count == 1 {
                // Unique winner
                let winnerID = winners[0].0
                holeWinners[hole.id] = winnerID
                playerSkins[winnerID, default: 0] += carriedValue
                carriedValue = 1  // Reset carry
            } else {
                // Tie
                holeWinners[hole.id] = nil
                if withCarry {
                    carriedValue += 1
                } else {
                    carriedValue = 1
                }
            }
        }
        
        return SkinsResult(
            playerSkins: playerSkins,
            holeWinners: holeWinners,
            holeValues: holeValues
        )
    }
}
