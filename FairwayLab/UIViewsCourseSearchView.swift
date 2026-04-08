//
//  CourseSearchView.swift
//  GolfX
//
//  View for searching and selecting golf courses from API
//

import SwiftUI

struct CourseSearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var apiClient = GolfCourseAPIClient.shared
    
    @State private var searchText = ""
    @State private var searchResults: [APICourseSummary] = []
    @State private var isSearching = false
    @State private var selectedCourseId: String?
    @State private var errorMessage: String?
    
    let onCourseSelected: (Course) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Results or states
                if isSearching {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error)
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    emptyResultsView
                } else if searchResults.isEmpty {
                    instructionsView
                } else {
                    resultsListView
                }
            }
            .navigationTitle("Search Courses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search by course name or location", text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .onSubmit {
                    performSearch()
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    searchResults = []
                    errorMessage = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Searching courses...")
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                performSearch()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Courses Found")
                .font(.headline)
            
            Text("Try a different search term")
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("Find Your Course")
                .font(.headline)
            
            Text("Search by course name, city, or location")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                exampleRow(icon: "location.fill", text: "\"Pebble Beach\"")
                exampleRow(icon: "location.fill", text: "\"Augusta National\"")
                exampleRow(icon: "location.fill", text: "\"St Andrews\"")
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
    }
    
    private func exampleRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var resultsListView: some View {
        List(searchResults) { course in
            Button(action: {
                selectCourse(course)
            }) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(course.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !course.locationString.isEmpty {
                        HStack {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(course.locationString)
                                .font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .disabled(selectedCourseId == course.id)
            .overlay(alignment: .trailing) {
                if selectedCourseId == course.id {
                    ProgressView()
                        .padding(.trailing)
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Actions
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        Task {
            isSearching = true
            errorMessage = nil
            
            do {
                searchResults = try await apiClient.searchCourses(query: searchText)
            } catch {
                errorMessage = error.localizedDescription
                searchResults = []
            }
            
            isSearching = false
        }
    }
    
    private func selectCourse(_ courseSummary: APICourseSummary) {
        selectedCourseId = courseSummary.id
        errorMessage = nil
        
        Task {
            do {
                let apiDetail = try await apiClient.fetchCourseDetail(id: courseSummary.id)
                let course = apiClient.mapToEngineCourse(apiDetail)
                
                await MainActor.run {
                    onCourseSelected(course)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load course details: \(error.localizedDescription)"
                    selectedCourseId = nil
                }
            }
        }
    }
}

#Preview {
    CourseSearchView { course in
        print("Selected: \(course.name)")
    }
}
