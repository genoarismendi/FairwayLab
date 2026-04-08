//
//  SkinsCalculatorTests.swift
//  GolfXTests
//
//  Unit tests for Skins calculations
//

import XCTest
@testable import GolfX

final class SkinsCalculatorTests: XCTestCase {
    
    func testSkinsUniqueWinner() async throws {
        let players = [
            Player(name: "Alice", handicap: 0),
            Player(name: "Bob", handicap: 0)
        ]
        
        let holes = [
            HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 1, yardage: 400)
        ]
        
        let scores: [UUID: [UUID: Int]] = [
            players[0].id: [holes[0].id: 4],  // Alice: 4
            players[1].id: [holes[0].id: 5]   // Bob: 5
        ]
        
        let input = CalculationInput(
            players: players,
            holes: holes,
            handicapMode: .absolute,
            scores: scores,
            kpWinners: [:]
        )
        
        let tee = Tee(
            name: "Test",
            courseRating: 72.0,
            slope: 113,
            pars: [4],
            yardages: [400],
            strokeIndices: [1]
        )
        
        let result = SkinsCalculator.calculate(input: input, tee: tee, useNet: false, withCarry: false)
        
        XCTAssertEqual(result.totalSkins(for: players[0].id), 1, "Alice wins 1 skin")
        XCTAssertEqual(result.totalSkins(for: players[1].id), 0, "Bob wins 0 skins")
    }
    
    func testSkinsWithCarry() async throws {
        let players = [
            Player(name: "Alice", handicap: 0),
            Player(name: "Bob", handicap: 0)
        ]
        
        let holes = [
            HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 1, yardage: 400),
            HoleDefinition(actualHoleNumber: 2, displayOrder: 2, par: 4, strokeIndex: 2, yardage: 400),
            HoleDefinition(actualHoleNumber: 3, displayOrder: 3, par: 4, strokeIndex: 3, yardage: 400)
        ]
        
        let scores: [UUID: [UUID: Int]] = [
            players[0].id: [
                holes[0].id: 4,  // Tie
                holes[1].id: 4,  // Tie
                holes[2].id: 4   // Alice wins
            ],
            players[1].id: [
                holes[0].id: 4,  // Tie
                holes[1].id: 4,  // Tie
                holes[2].id: 5   // Bob loses
            ]
        ]
        
        let input = CalculationInput(
            players: players,
            holes: holes,
            handicapMode: .absolute,
            scores: scores,
            kpWinners: [:]
        )
        
        let tee = Tee(
            name: "Test",
            courseRating: 72.0,
            slope: 113,
            pars: [4, 4, 4],
            yardages: [400, 400, 400],
            strokeIndices: [1, 2, 3]
        )
        
        let result = SkinsCalculator.calculate(input: input, tee: tee, useNet: false, withCarry: true)
        
        XCTAssertEqual(result.totalSkins(for: players[0].id), 3, "Alice wins 3 skins (1 + 1 carry + 1 carry)")
        XCTAssertEqual(result.holeValues[holes[2].id], 3, "Hole 3 should be worth 3 skins")
    }
}
