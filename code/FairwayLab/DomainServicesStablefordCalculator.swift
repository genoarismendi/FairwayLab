//
//  StablefordCalculator.swift
//  GolfX
//
//  Service for calculating Stableford points
//

import Foundation

struct StablefordResult: Codable {
    let playerPoints: [UUID: Int]  // playerID -> total points
    let holePoints: [UUID: [UUID: Int]]  // playerID -> holeID -> points
    
    func totalPoints(for playerID: UUID) -> Int {
        playerPoints[playerID] ?? 0
    }
    
    func sortedPlayers(players: [Player]) -> [(Player, Int)] {
        players.map { player in
            (player, totalPoints(for: player.id))
        }.sorted { $0.1 > $1.1 }
    }
}

struct StablefordCalculator {
    
    /// Calculate Stableford points based on score relative to par
    static func points(netScore: Int, par: Int) -> Int {
        let scoreDiff = netScore - par
        
        switch scoreDiff {
        case ...(-2):  // Eagle or better
            return 4
        case -1:       // Birdie
            return 3
        case 0:        // Par
            return 2
        case 1:        // Bogey
            return 1
        default:       // Double bogey or worse
            return 0
        }
    }
    
    /// Calculate Stableford results for the round
    static func calculate(
        input: CalculationInput,
        tee: Tee,
        useNet: Bool
    ) -> StablefordResult {
        var playerPoints: [UUID: Int] = [:]
        var holePoints: [UUID: [UUID: Int]] = [:]
        
        // Calculate playing handicaps
        let playingHandicaps = HandicapCalculator.calculatePlayingHandicaps(
            players: input.players,
            slope: tee.slope,
            courseRating: tee.courseRating,
            par: input.holes.map { $0.par }.reduce(0, +),
            mode: input.handicapMode
        )
        
        for player in input.players {
            var totalPoints = 0
            holePoints[player.id] = [:]
            
            let playingHandicap = playingHandicaps[player.id] ?? 0
            let strokesPerHole = HandicapCalculator.strokesPerHole(
                playingHandicap: playingHandicap,
                holes: input.holes
            )
            
            for hole in input.holes {
                guard let grossScore = input.score(playerID: player.id, holeID: hole.id),
                      grossScore > 0 else {
                    continue
                }
                
                let netScore: Int
                if useNet {
                    let strokes = strokesPerHole[hole.id] ?? 0
                    netScore = grossScore - strokes
                } else {
                    netScore = grossScore
                }
                
                let pts = points(netScore: netScore, par: hole.par)
                totalPoints += pts
                holePoints[player.id]?[hole.id] = pts
            }
            
            playerPoints[player.id] = totalPoints
        }
        
        return StablefordResult(playerPoints: playerPoints, holePoints: holePoints)
    }
}
