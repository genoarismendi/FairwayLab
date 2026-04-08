//
//  HoleBuilderTests.swift
//  GolfXTests
//
//  Unit tests for hole building and validation
//

import XCTest
@testable import GolfX

final class HoleBuilderTests: XCTestCase {
    
    func testBuildFront9() async throws {
        let tee = MockCourseData.sampleTee1
        let holes = HoleBuilder.buildHoles(from: tee, isNineHole: true, isBackNine: false)
        
        XCTAssertEqual(holes.count, 9)
        XCTAssertEqual(holes[0].actualHoleNumber, 1)
        XCTAssertEqual(holes[8].actualHoleNumber, 9)
        XCTAssertEqual(holes[0].displayOrder, 1)
        XCTAssertEqual(holes[8].displayOrder, 9)
    }
    
    func testBuildBack9() async throws {
        let tee = MockCourseData.sampleTee1
        let holes = HoleBuilder.buildHoles(from: tee, isNineHole: true, isBackNine: true)
        
        XCTAssertEqual(holes.count, 9)
        XCTAssertEqual(holes[0].actualHoleNumber, 10)
        XCTAssertEqual(holes[8].actualHoleNumber, 18)
        XCTAssertEqual(holes[0].displayOrder, 1)
        XCTAssertEqual(holes[8].displayOrder, 9)
    }
    
    func testBuild18Holes() async throws {
        let tee = MockCourseData.sampleTee1
        let holes = HoleBuilder.buildHoles(from: tee, isNineHole: false, isBackNine: false)
        
        XCTAssertEqual(holes.count, 18)
        XCTAssertEqual(holes[0].actualHoleNumber, 1)
        XCTAssertEqual(holes[17].actualHoleNumber, 18)
    }
    
    func testValidateStrokeIndicesValid() async throws {
        let holes = [
            HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 1, yardage: 400),
            HoleDefinition(actualHoleNumber: 2, displayOrder: 2, par: 4, strokeIndex: 2, yardage: 400),
            HoleDefinition(actualHoleNumber: 3, displayOrder: 3, par: 3, strokeIndex: 3, yardage: 180)
        ]
        
        XCTAssertTrue(HoleBuilder.validateStrokeIndices(holes))
    }
    
    func testValidateStrokeIndicesInvalid() async throws {
        let holes = [
            HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 1, yardage: 400),
            HoleDefinition(actualHoleNumber: 2, displayOrder: 2, par: 4, strokeIndex: 1, yardage: 400),
            HoleDefinition(actualHoleNumber: 3, displayOrder: 3, par: 3, strokeIndex: 3, yardage: 180)
        ]
        
        XCTAssertFalse(HoleBuilder.validateStrokeIndices(holes))
    }
    
    func testNormalizeStrokeIndices() async throws {
        let holes = [
            HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 10, yardage: 400),
            HoleDefinition(actualHoleNumber: 2, displayOrder: 2, par: 4, strokeIndex: 10, yardage: 400),
            HoleDefinition(actualHoleNumber: 3, displayOrder: 3, par: 3, strokeIndex: 10, yardage: 180)
        ]
        
        let normalized = HoleBuilder.normalizeStrokeIndices(holes)
        
        XCTAssertEqual(normalized[0].strokeIndex, 1)
        XCTAssertEqual(normalized[1].strokeIndex, 2)
        XCTAssertEqual(normalized[2].strokeIndex, 3)
    }
    
    func testNineHoleStrokeIndexRenormalization() async throws {
        // Create a tee with 18-hole stroke indices
        let tee = Tee(
            name: "Test",
            courseRating: 72.0,
            slope: 113,
            pars: Array(repeating: 4, count: 18),
            yardages: Array(repeating: 400, count: 18),
            strokeIndices: [5, 9, 3, 13, 17, 1, 15, 11, 7, 6, 10, 2, 14, 18, 4, 16, 12, 8]
        )
        
        // Build front 9
        let front9 = HoleBuilder.buildHoles(from: tee, isNineHole: true, isBackNine: false)
        
        // Verify we have 9 holes
        XCTAssertEqual(front9.count, 9)
        
        // Verify stroke indices are renormalized to 1-9
        let strokeIndices = front9.map { $0.strokeIndex }.sorted()
        XCTAssertEqual(strokeIndices, [1, 2, 3, 4, 5, 6, 7, 8, 9], "Stroke indices should be renormalized to 1-9")
        
        // Verify relative difficulty is preserved (hole with SI 1 in original should have SI 1 in subset)
        let hardestHole = front9.first { $0.strokeIndex == 1 }
        XCTAssertNotNil(hardestHole, "Should have a hole with SI 1")
        XCTAssertEqual(hardestHole?.actualHoleNumber, 6, "Hole 6 had SI 1 originally, should still be hardest")
        
        // Verify validation passes
        XCTAssertTrue(HoleBuilder.validateStrokeIndices(front9), "Renormalized indices should be valid")
    }
}
