import Foundation

// MARK: - Modelos
struct Segment: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String?
}

// Estrutura para o POST
struct CreateSegmentRequest: Codable {
    let name: String
    let description: String
}

// MARK: - Serviço
protocol SegmentServiceProtocol: Sendable {
    func getSegments() async throws -> [Segment]
    func createSegment(name: String, description: String) async throws -> String
    func deleteSegment(id: String) async throws
}

final class SegmentService: SegmentServiceProtocol, @unchecked Sendable {
    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = .shared, baseURL: URL = APIConfig.baseUrl) {
        self.session = session
        self.baseURL = baseURL
    }

    func getSegments() async throws -> [Segment] {
        let url = baseURL.appendingPathComponent("Segments")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        injectToken(into: &request)

        let (data, response) = try await session.data(for: request)
        guard response is HTTPURLResponse else { throw AppError.unknown }
        return try data.decodeBaseResponse()
    }

    func createSegment(name: String, description: String) async throws -> String {
        let url = baseURL.appendingPathComponent("Segments")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        injectToken(into: &request)
        
        let body = CreateSegmentRequest(name: name, description: description)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard response is HTTPURLResponse else { throw AppError.unknown }
        return try data.decodeBaseResponse()
    }

    func deleteSegment(id: String) async throws {
        let url = baseURL.appendingPathComponent("Segments/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        injectToken(into: &request)

        let (data, response) = try await session.data(for: request)
        guard response is HTTPURLResponse else { throw AppError.unknown }
        
        let _: Bool = try data.decodeBaseResponse()
    }
    
    func updateSegment(id: String, name: String, description: String) async throws {
        let url = baseURL.appendingPathComponent("Segments/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        injectToken(into: &request)
        
        let body = CreateSegmentRequest(name: name, description: description)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard response is HTTPURLResponse else { throw AppError.unknown }
        
        let _: Bool = try data.decodeBaseResponse()
    }

    private func injectToken(into request: inout URLRequest) {
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
