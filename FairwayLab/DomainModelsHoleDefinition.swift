//
//  HoleDefinition.swift
//  GolfX
//
//  Domain model for a hole in a golf round
//

import Foundation

struct HoleDefinition: Identifiable, Hashable, Codable {
    let id: UUID
    let actualHoleNumber: Int  // 1-18, the actual course hole number
    let displayOrder: Int       // 1-N, order in the round
    let par: Int
    var strokeIndex: Int
    let yardage: Int
    
    init(
        id: UUID = UUID(),
        actualHoleNumber: Int,
        displayOrder: Int,
        par: Int,
        strokeIndex: Int,
        yardage: Int
    ) {
        self.id = id
        self.actualHoleNumber = actualHoleNumber
        self.displayOrder = displayOrder
        self.par = par
        self.strokeIndex = strokeIndex
        self.yardage = yardage
    }
    
    var isPar3: Bool {
        par == 3
    }
}
