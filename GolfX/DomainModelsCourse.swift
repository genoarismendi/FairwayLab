//
//  Course.swift
//  GolfX
//
//  Domain model for a golf course
//

import Foundation

struct Course: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let tees: [Tee]
    
    init(id: UUID = UUID(), name: String, tees: [Tee]) {
        self.id = id
        self.name = name
        self.tees = tees
    }
}
