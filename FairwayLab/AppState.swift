import Foundation
import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    // Active round state
    @Published var roundDefinition: RoundDefinition? {
        didSet { saveToUserDefaults() }
    }
    @Published var roundState: RoundState? {
        didSet { saveToUserDefaults() }
    }

    // Last valid definition for reuse
    @Published var lastValidRoundDefinition: RoundDefinition? {
        didSet { saveToUserDefaults() }
    }

    // Navigation flags
    @Published var isSetupPresented = false
    @Published var isPlayPresented = false
    @Published var isResultsPresented = false
    
    // Persistence keys
    private enum Keys {
        static let roundDefinition = "com.golfx.roundDefinition"
        static let roundState = "com.golfx.roundState"
        static let lastValidDefinition = "com.golfx.lastValidDefinition"
    }

    init() {
        // Try to restore from UserDefaults
        loadFromUserDefaults()
    }

    func startNewRound() {
        roundDefinition = nil
        roundState = nil
        clearUserDefaults()
        isSetupPresented = true
    }

    func continueRound() -> Bool {
        roundDefinition != nil && roundState != nil
    }

    func finalizeSetup(definition: RoundDefinition) {
        self.roundDefinition = definition
        self.lastValidRoundDefinition = definition
        self.roundState = RoundState(players: definition.players, holes: definition.holes)
        self.isSetupPresented = false
        self.isPlayPresented = true
    }

    func resetToLastValid() {
        if let last = lastValidRoundDefinition {
            finalizeSetup(definition: last)
        }
    }
    
    func showResults() {
        isPlayPresented = false
        isResultsPresented = true
    }
    
    func backToPlay() {
        isResultsPresented = false
        isPlayPresented = true
    }
    
    func endRound() {
        roundDefinition = nil
        roundState = nil
        clearUserDefaults()
        isPlayPresented = false
        isResultsPresented = false
    }
    
    // MARK: - Persistence
    
    /// Save current state to UserDefaults
    private func saveToUserDefaults() {
        let encoder = JSONEncoder()
        
        // Save round definition
        if let definition = roundDefinition,
           let data = try? encoder.encode(definition) {
            UserDefaults.standard.set(data, forKey: Keys.roundDefinition)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.roundDefinition)
        }
        
        // Save round state
        if let state = roundState,
           let data = try? encoder.encode(state) {
            UserDefaults.standard.set(data, forKey: Keys.roundState)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.roundState)
        }
        
        // Save last valid definition
        if let lastValid = lastValidRoundDefinition,
           let data = try? encoder.encode(lastValid) {
            UserDefaults.standard.set(data, forKey: Keys.lastValidDefinition)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.lastValidDefinition)
        }
    }
    
    /// Load saved state from UserDefaults
    private func loadFromUserDefaults() {
        let decoder = JSONDecoder()
        
        // Load round definition
        if let data = UserDefaults.standard.data(forKey: Keys.roundDefinition),
           let definition = try? decoder.decode(RoundDefinition.self, from: data) {
            self.roundDefinition = definition
        }
        
        // Load round state
        if let data = UserDefaults.standard.data(forKey: Keys.roundState),
           let state = try? decoder.decode(RoundState.self, from: data) {
            self.roundState = state
        }
        
        // Load last valid definition
        if let data = UserDefaults.standard.data(forKey: Keys.lastValidDefinition),
           let lastValid = try? decoder.decode(RoundDefinition.self, from: data) {
            self.lastValidRoundDefinition = lastValid
        }
    }
    
    /// Clear all saved data
    private func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: Keys.roundDefinition)
        UserDefaults.standard.removeObject(forKey: Keys.roundState)
        // Note: We keep lastValidDefinition for "Repeat Last Setup"
    }
    
    /// Manually save (called from views when needed)
    func forceSave() {
        saveToUserDefaults()
    }
}
