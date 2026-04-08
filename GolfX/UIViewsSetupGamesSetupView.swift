//
//  GamesSetupView.swift
//  GolfX
//
//  Games selection setup step
//

import SwiftUI

struct GamesSetupView: View {
    @ObservedObject var viewModel: SetupWizardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Games")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("Choose which games to play")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Form {
                Section("Handicap Mode") {
                    Picker("Mode", selection: $viewModel.handicapMode) {
                        ForEach(HandicapMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text(viewModel.handicapMode.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Select Games") {
                    ForEach(GameType.allCases) { game in
                        GameToggleRow(
                            game: game,
                            isSelected: viewModel.selectedGames.contains(game),
                            isValid: !game.requiresValidStrokeIndex || viewModel.strokeIndexIsValid,
                            toggle: {
                                viewModel.toggleGame(game)
                            }
                        )
                    }
                }
            }
        }
    }
}

struct GameToggleRow: View {
    let game: GameType
    let isSelected: Bool
    let isValid: Bool
    let toggle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(game.displayName)
                    .font(.body)
                
                if game.requiresValidStrokeIndex && !isValid {
                    Text("⚠️ Requires valid stroke index")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { _ in toggle() }
            ))
            .disabled(game.requiresValidStrokeIndex && !isValid)
        }
    }
}
