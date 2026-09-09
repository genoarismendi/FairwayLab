//
//  RoundDetailsSetupView.swift
//  GolfX
//
//  Round details setup step
//

import SwiftUI

struct RoundDetailsSetupView: View {
    @ObservedObject var viewModel: SetupWizardViewModel
    @State private var showingCourseSearch = false
    @State private var showingStrokeIndexEditor = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Round Details")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("Select course, tee, and holes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Form {
                Section("Holes") {
                    Picker("Hole Count", selection: $viewModel.isNineHole) {
                        Text("18 Holes").tag(false)
                        Text("9 Holes").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.isNineHole) { _, newValue in
                        viewModel.updateHoleSelection(nineHole: newValue, backNine: viewModel.isBackNine)
                    }
                    
                    if viewModel.isNineHole {
                        Picker("Which 9", selection: $viewModel.isBackNine) {
                            Text("Front 9").tag(false)
                            Text("Back 9").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: viewModel.isBackNine) { _, newValue in
                            viewModel.updateHoleSelection(nineHole: viewModel.isNineHole, backNine: newValue)
                        }
                    }
                }
                
                Section("Course") {
                    if let course = viewModel.selectedCourse {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(course.name)
                                    .font(.headline)
                                Text("\(course.tees.count) tee\(course.tees.count == 1 ? "" : "s") available")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Change") {
                                showingCourseSearch = true
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        Button(action: {
                            showingCourseSearch = true
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search for Course")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Quick access to mock courses for testing
                        Menu("Or use test course") {
                            ForEach(MockCourseData.allCourses) { course in
                                Button(course.name) {
                                    viewModel.selectCourse(course)
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                
                if let course = viewModel.selectedCourse {
                    Section("Tee") {
                        Picker("Tee", selection: $viewModel.selectedTee) {
                            ForEach(course.tees) { tee in
                                Text(tee.name).tag(tee as Tee?)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: viewModel.selectedTee) { _, newValue in
                            if let tee = newValue {
                                viewModel.selectTee(tee)
                            }
                        }
                    }
                    
                    if let tee = viewModel.selectedTee {
                        Section("Tee Info") {
                            HStack {
                                Text("Rating:")
                                Spacer()
                                Text(String(format: "%.1f", tee.courseRating))
                            }
                            HStack {
                                Text("Slope:")
                                Spacer()
                                Text("\(tee.slope)")
                            }
                            HStack {
                                Text("Par:")
                                Spacer()
                                Text("\(viewModel.holes.map { $0.par }.reduce(0, +))")
                            }
                        }
                        
                        if !viewModel.holes.isEmpty {
                            Section {
                                Button(action: {
                                    showingStrokeIndexEditor = true
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Stroke Index")
                                                .font(.headline)
                                            if viewModel.strokeIndexIsValid {
                                                Text("Valid • Tap to customize")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            } else {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .font(.caption2)
                                                    Text("Invalid • Tap to fix")
                                                        .font(.caption)
                                                }
                                                .foregroundStyle(.orange)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .foregroundStyle(.primary)
                            } header: {
                                Text("Hole Configuration")
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingCourseSearch) {
            CourseSearchView { selectedCourse in
                viewModel.selectCourse(selectedCourse)
            }
        }
        .sheet(isPresented: $showingStrokeIndexEditor) {
            StrokeIndexEditorView(viewModel: viewModel)
        }
    }
}
