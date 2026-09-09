//
//  GolfCourseAPIClient.swift
//  GolfX
//
//  API client for fetching real golf course data
//

import Foundation
import Combine

// MARK: - API Models

struct APICourseSearchResponse: Decodable {
    let courses: [APICourseSummary]
}

struct APICourseSummary: Decodable, Identifiable {
    let id: String
    let name: String
    let city: String?
    let state: String?
    let country: String?

    private enum CodingKeys: String, CodingKey {
        case id, club_name, course_name, location
    }

    private enum LocationKeys: String, CodingKey {
        case address, city, state, country
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let intId = try? container.decode(Int.self, forKey: .id) {
            self.id = String(intId)
        } else if let strId = try? container.decode(String.self, forKey: .id) {
            self.id = strId
        } else {
            self.id = UUID().uuidString
        }

        let clubName = try? container.decode(String.self, forKey: .club_name)
        let courseName = try? container.decode(String.self, forKey: .course_name)
        self.name = courseName ?? clubName ?? "Unknown course"

        if let loc = try? container.nestedContainer(keyedBy: LocationKeys.self, forKey: .location) {
            self.city = try? loc.decode(String.self, forKey: .city)
            self.state = try? loc.decode(String.self, forKey: .state)
            self.country = try? loc.decode(String.self, forKey: .country)
        } else {
            self.city = nil
            self.state = nil
            self.country = nil
        }
    }
    
    var locationString: String {
        [city, state, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

// MARK: - Course Detail

struct APICourseDetail: Decodable {
    let id: Int
    let club_name: String
    let course_name: String
    let location: Location?
    let tees: TeesByGender

    struct Location: Decodable {
        let address: String?
        let city: String?
        let state: String?
        let country: String?
        let latitude: Double?
        let longitude: Double?
    }

    struct TeesByGender: Decodable {
        let female: [TeeVariant]?
        let male: [TeeVariant]?
    }

    struct TeeVariant: Decodable {
        let tee_name: String
        let course_rating: Double?
        let slope_rating: Int?
        let bogey_rating: Double?
        let total_yards: Int?
        let total_meters: Int?
        let number_of_holes: Int
        let par_total: Int
        let front_course_rating: Double?
        let front_slope_rating: Int?
        let front_bogey_rating: Double?
        let back_course_rating: Double?
        let back_slope_rating: Int?
        let back_bogey_rating: Double?
        let holes: [TeeHole]

        struct TeeHole: Decodable {
            let par: Int
            let yardage: Int
            let handicap: Int
        }
    }
}

struct APICourseDetailResponse: Decodable {
    let course: APICourseDetail
}

// MARK: - Errors

enum GolfCourseAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int, body: String?)
    case decodingFailed
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .requestFailed(let code, _):
            return "Request failed with status code \(code)"
        case .decodingFailed:
            return "Failed to decode API response"
        case .missingAPIKey:
            return "API key not found in configuration"
        }
    }
}

// MARK: - Client

@MainActor
final class GolfCourseAPIClient: ObservableObject {
    static let shared = GolfCourseAPIClient()

    private let baseURL = URL(string: "https://api.golfcourseapi.com")!

    private let apiKey: String = {
        let rawKey: String
        if let key = Bundle.main.infoDictionary?["GOLF_API_KEY"] as? String, !key.isEmpty {
            rawKey = key
        } else {
            print("⚠️ GOLF_API_KEY not found in Info.plist, using fallback")
            // Fallback API key for development
            rawKey = "LLOACD7TDCZ66UQVAOQFUWHRLM"
        }
        
        // Clean the API key: remove whitespace and invisible characters
        let cleanedKey = rawKey
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\u{200B}", with: "") // Zero-width space
            .replacingOccurrences(of: "\u{200C}", with: "") // Zero-width non-joiner
            .replacingOccurrences(of: "\u{200D}", with: "") // Zero-width joiner
            .replacingOccurrences(of: "\u{FEFF}", with: "") // Zero-width no-break space
            .replacingOccurrences(of: " ", with: "")        // Regular spaces
        
        print("✅ Cleaned API Key: \(cleanedKey)")
        return cleanedKey
    }()

    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var courseDetailCache: [String: APICourseDetail] = [:]

    private init() {}

    func searchCourses(query: String) async throws -> [APICourseSummary] {
        guard !apiKey.isEmpty else {
            throw GolfCourseAPIError.missingAPIKey
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        var components = URLComponents(
            url: baseURL.appendingPathComponent("v1/search"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [URLQueryItem(name: "search_query", value: query)]

        guard let url = components?.url else {
            throw GolfCourseAPIError.invalidURL
        }

        print("🌐 Search URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addHeaders(&request)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw GolfCourseAPIError.requestFailed(statusCode: -1, body: nil)
        }
        
        print("📡 Search API Response: Status \(http.statusCode)")
        
        guard (200...299).contains(http.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8)
            print("❌ Search API Error \(http.statusCode): \(errorBody ?? "No body")")
            throw GolfCourseAPIError.requestFailed(
                statusCode: http.statusCode,
                body: errorBody
            )
        }

        do {
            return try JSONDecoder().decode(APICourseSearchResponse.self, from: data).courses
        } catch {
            print("❌ Decoding error: \(error)")
            throw GolfCourseAPIError.decodingFailed
        }
    }

    func fetchCourseDetail(id: String) async throws -> APICourseDetail {
        guard !apiKey.isEmpty else {
            throw GolfCourseAPIError.missingAPIKey
        }
        
        if let cached = courseDetailCache[id] {
            return cached
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let url = baseURL.appendingPathComponent("v1/courses/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addHeaders(&request)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw GolfCourseAPIError.requestFailed(statusCode: -1, body: nil)
        }
        guard (200...299).contains(http.statusCode) else {
            throw GolfCourseAPIError.requestFailed(
                statusCode: http.statusCode,
                body: String(data: data, encoding: .utf8)
            )
        }

        do {
            let decoded = try JSONDecoder().decode(APICourseDetailResponse.self, from: data)
            courseDetailCache[id] = decoded.course
            return decoded.course
        } catch {
            print("❌ Decoding error: \(error)")
            throw GolfCourseAPIError.decodingFailed
        }
    }

    /// Convert API course detail to domain Course model
    func mapToEngineCourse(_ api: APICourseDetail) -> Course {
        let variants = flattenTees(api.tees)
        
        let tees = variants.compactMap { teeVariant -> Tee? in
            // Only use 18-hole tees
            guard teeVariant.holes.count == 18 else { return nil }
            
            let pars = teeVariant.holes.map { $0.par }
            let yardages = teeVariant.holes.map { $0.yardage }
            let strokeIndices = teeVariant.holes.map { $0.handicap }
            
            return Tee(
                name: teeVariant.tee_name,
                courseRating: teeVariant.course_rating ?? 72.0,
                slope: teeVariant.slope_rating ?? 113,
                pars: pars,
                yardages: yardages,
                strokeIndices: strokeIndices
            )
        }
        
        return Course(
            name: "\(api.club_name) - \(api.course_name)",
            tees: tees.isEmpty ? [createDefaultTee()] : tees
        )
    }
    
    /// Create a default 18-hole tee if API doesn't provide valid data
    private func createDefaultTee() -> Tee {
        let defaultPars = [4, 4, 3, 5, 4, 4, 3, 4, 5, 4, 4, 3, 5, 4, 4, 3, 4, 5]
        let defaultYardages = [350, 380, 150, 500, 400, 370, 180, 420, 520, 360, 390, 160, 510, 380, 350, 170, 410, 530]
        
        return Tee(
            name: "Default",
            courseRating: 72.0,
            slope: 113,
            pars: defaultPars,
            yardages: defaultYardages
        )
    }

    private func flattenTees(_ tees: APICourseDetail.TeesByGender) -> [APICourseDetail.TeeVariant] {
        (tees.male ?? []) + (tees.female ?? [])
    }

    private func addHeaders(_ request: inout URLRequest) {
        // Try different authentication formats
        let authValue = "Key \(apiKey)"
        print("🔑 API Key: \(apiKey)")
        print("🔑 Authorization Header: \(authValue)")
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
    }
}
