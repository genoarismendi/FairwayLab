//
//  ReviewSetupView.swift
//  GolfX
//
//  Review setup before starting round
//

import SwiftUI

struct ReviewSetupView: View {
    @ObservedObject var viewModel: SetupWizardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Review")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("Confirm setup and start round")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            List {
                Section("Players") {
                    ForEach(viewModel.players) { player in
                        HStack {
                            Text(player.name.isEmpty ? "Unnamed Player" : player.name)
                            Spacer()
                            Text("HCP: \(String(format: "%.1f", player.handicap))")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                if let course = viewModel.selectedCourse,
                   let tee = viewModel.selectedTee {
                    Section("Round") {
                        HStack {
                            Text("Course")
                            Spacer()
                            Text(course.name)
                        }
                        HStack {
                            Text("Tee")
                            Spacer()
                            Text(tee.name)
                        }
                        HStack {
                            Text("Holes")
                            Spacer()
                            if viewModel.isNineHole {
                                Text("\(viewModel.isBackNine ? "Back" : "Front") 9")
                            } else {
                                Text("18 Holes")
                            }
                        }
                        HStack {
                            Text("Par")
                            Spacer()
                            Text("\(viewModel.holes.map { $0.par }.reduce(0, +))")
                        }
                    }
                }
                
                Section("Games") {
                    ForEach(Array(viewModel.selectedGames).sorted(by: { $0.displayName < $1.displayName })) { game in
                        Text(game.displayName)
                    }
                    
                    HStack {
                        Text("Handicap Mode")
                        Spacer()
                        Text(viewModel.handicapMode.displayName)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if !viewModel.canStart {
                    Section {
                        ForEach(viewModel.validationErrors, id: \.self) { error in
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text(error)
                            }
                        }
                    } header: {
                        Text("Validation Errors")
                    }
                }
            }
        }
    }
}
