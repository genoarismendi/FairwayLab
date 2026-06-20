//
//  CalculationInputMapper.swift
//  GolfX
//
//  Service to map RoundDefinition + RoundState into CalculationInput
//

import Foundation

struct CalculationInputMapper {
    
    /// Create immutable calculation input from round definition and state
    static func createInput(
        definition: RoundDefinition,
        state: RoundState
    ) -> CalculationInput {
        // Extract all scores
        var scores: [UUID: [UUID: Int]] = [:]
        for player in definition.players {
            var playerScores: [UUID: Int] = [:]
            for hole in definition.holes {
                if let score = state.getGrossScore(for: player.id, holeID: hole.id) {
                    playerScores[hole.id] = score
                }
            }
            scores[player.id] = playerScores
        }
        
        // Extract KP winners
        var kpWinners: [UUID: UUID?] = [:]
        for hole in definition.holes where hole.isPar3 {
            kpWinners[hole.id] = state.getKPWinner(for: hole.id)
        }

        // Extract putts
        var allPutts: [UUID: [UUID: Int]] = [:]
        for player in definition.players {
            var playerPutts: [UUID: Int] = [:]
            for hole in definition.holes {
                if let p = state.getPutts(for: player.id, holeID: hole.id) {
                    playerPutts[hole.id] = p
                }
            }
            allPutts[player.id] = playerPutts
        }

        return CalculationInput(
            players: definition.players,
            holes: definition.holes,
            handicapMode: definition.handicapMode,
            scores: scores,
            kpWinners: kpWinners,
            putts: allPutts
        )
    }
}
