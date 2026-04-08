//
//  SetupWizardView.swift
//  GolfX
//
//  Setup wizard for configuring a new round
//

import SwiftUI

struct SetupWizardView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = SetupWizardViewModel()
    
    var body: some View {
        NavigationStack {
            TabView(selection: $viewModel.currentStep) {
                PlayersSetupView(viewModel: viewModel)
                    .tag(SetupStep.players)
                
                RoundDetailsSetupView(viewModel: viewModel)
                    .tag(SetupStep.roundDetails)
                
                GamesSetupView(viewModel: viewModel)
                    .tag(SetupStep.games)
                
                ReviewSetupView(viewModel: viewModel)
                    .tag(SetupStep.review)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .navigationTitle("New Round Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.currentStep == .review {
                        Button("Start Round") {
                            if viewModel.canStart {
                                let definition = viewModel.buildRoundDefinition()
                                appState.finalizeSetup(definition: definition)
                                dismiss()
                            }
                        }
                        .disabled(!viewModel.canStart)
                        .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

enum SetupStep: Int, CaseIterable {
    case players = 0
    case roundDetails = 1
    case games = 2
    case review = 3
    
    var title: String {
        switch self {
        case .players: return "Players"
        case .roundDetails: return "Round Details"
        case .games: return "Games"
        case .review: return "Review"
        }
    }
}

#Preview {
    SetupWizardView()
        .environmentObject(AppState())
}
