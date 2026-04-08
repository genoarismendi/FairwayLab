//
//  ResultsViewModel.swift
//  GolfX
//
//  View model for calculating and presenting results
//

import Foundation
import Combine

@MainActor
class ResultsViewModel: ObservableObject {
    let definition: RoundDefinition
    let state: RoundState
    let input: CalculationInput
    
    @Published var stablefordResult: StablefordResult?
    @Published var skinsResult: SkinsResult?
    @Published var nassauResult: NassauResult?
    @Published var kpResult: KPResult?
    @Published var caraEPerroResult: CaraEPerroResult?
    
    init(definition: RoundDefinition, state: RoundState) {
        self.definition = definition
        self.state = state
        self.input = CalculationInputMapper.createInput(definition: definition, state: state)
        
        calculateResults()
    }
    
    func calculateResults() {
        // Stableford
        if definition.selectedGames.contains(.stableford) {
            stablefordResult = StablefordCalculator.calculate(
                input: input,
                tee: definition.tee,
                useNet: true
            )
        }
        
        // Skins
        if definition.selectedGames.contains(.skins) {
            skinsResult = SkinsCalculator.calculate(
                input: input,
                tee: definition.tee,
                useNet: true,
                withCarry: true
            )
        }
        
        // Nassau
        if definition.selectedGames.contains(.nassau) {
            nassauResult = NassauCalculator.calculate(
                input: input,
                tee: definition.tee
            )
        }
        
        // KP
        if definition.selectedGames.contains(.kp) {
            kpResult = KPCalculator.calculate(input: input)
        }
        
        // Cara 'e Perro
        if definition.selectedGames.contains(.caraEPerro) {
            caraEPerroResult = CaraEPerroCalculator.calculate(
                input: input,
                tee: definition.tee
            )
        }
    }
}
