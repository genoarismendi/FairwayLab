//
//  StablefordCalculatorTests.swift
//  GolfXTests
//
//  Unit tests for Stableford scoring
//

import XCTest
@testable import GolfX

final class StablefordCalculatorTests: XCTestCase {
    
    func testStablefordPoints() async throws {
        XCTAssertEqual(StablefordCalculator.points(netScore: 3, par: 5), 4, "Eagle = 4 pts")
        XCTAssertEqual(StablefordCalculator.points(netScore: 4, par: 5), 3, "Birdie = 3 pts")
        XCTAssertEqual(StablefordCalculator.points(netScore: 5, par: 5), 2, "Par = 2 pts")
        XCTAssertEqual(StablefordCalculator.points(netScore: 6, par: 5), 1, "Bogey = 1 pt")
        XCTAssertEqual(StablefordCalculator.points(netScore: 7, par: 5), 0, "Double bogey = 0 pts")
        XCTAssertEqual(StablefordCalculator.points(netScore: 8, par: 5), 0, "Worse = 0 pts")
    }
    
    func testStablefordGrossScoring() async throws {
        let players = [
            Player(name: "Alice", handicap: 0)
        ]
        
        let holes = [
            HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 1, yardage: 400),
            HoleDefinition(actualHoleNumber: 2, displayOrder: 2, par: 5, strokeIndex: 2, yardage: 500)
        ]
        
        let scores: [UUID: [UUID: Int]] = [
            players[0].id: [
                holes[0].id: 4,  // Par
                holes[1].id: 4   // Birdie
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
            pars: [4, 5],
            yardages: [400, 500],
            strokeIndices: [1, 2]
        )
        
        let result = StablefordCalculator.calculate(input: input, tee: tee, useNet: false)
        
        let totalPoints = result.totalPoints(for: players[0].id)
        XCTAssertEqual(totalPoints, 5, "Par (2) + Birdie (3) = 5 points")
    }
}
