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
        
        // Extract all putts
        var putts: [UUID: [UUID: Int]] = [:]
        for player in definition.players {
            var playerPutts: [UUID: Int] = [:]
            for hole in definition.holes {
                if let puttCount = state.getPutts(for: player.id, holeID: hole.id) {
                    playerPutts[hole.id] = puttCount
                }
            }
            putts[player.id] = playerPutts
        }
        
        // Extract KP winners
        var kpWinners: [UUID: UUID?] = [:]
        for hole in definition.holes where hole.isPar3 {
            kpWinners[hole.id] = state.getKPWinner(for: hole.id)
        }
        
        return CalculationInput(
            players: definition.players,
            holes: definition.holes,
            handicapMode: definition.handicapMode,
            scores: scores,
            putts: putts,
            kpWinners: kpWinners
        )
    }
}
