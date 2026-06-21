//
//  PlayersSetupView.swift
//  GolfX
//
//  Players setup step
//

import SwiftUI

struct PlayersSetupView: View {
    @ObservedObject var viewModel: SetupWizardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Players")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("Add players and set their handicaps")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            List {
                ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                    PlayerRow(player: player, index: index, viewModel: viewModel)
                }
            }
            
            Button(action: {
                viewModel.addPlayer()
            }) {
                Label("Add Player", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if !viewModel.playersAreValid {
                Text("⚠️ At least 2 valid players required")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct PlayerRow: View {
    let player: Player
    let index: Int
    @ObservedObject var viewModel: SetupWizardViewModel
    
    @State private var name: String
    @State private var handicap: Double
    
    init(player: Player, index: Int, viewModel: SetupWizardViewModel) {
        self.player = player
        self.index = index
        self.viewModel = viewModel
        _name = State(initialValue: player.name)
        _handicap = State(initialValue: player.handicap)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("Player Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: name) { _, newValue in
                        updatePlayer()
                    }

                if index >= 2 {
                    Button(role: .destructive) {
                        viewModel.removePlayer(at: index)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }

            HStack {
                Text("Handicap:")
                    .foregroundStyle(.secondary)

                TextField("0.0", value: $handicap, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
                    .onChange(of: handicap) { _, _ in
                        updatePlayer()
                    }

                Stepper("", value: $handicap, in: 0...54, step: 0.5)
                    .labelsHidden()
                    .onChange(of: handicap) { _, _ in
                        updatePlayer()
                    }
            }
        }
        .padding(.vertical, 5)
    }
    
    private func updatePlayer() {
        let updated = Player(id: player.id, name: name, handicap: handicap)
        viewModel.updatePlayer(updated)
    }
}
