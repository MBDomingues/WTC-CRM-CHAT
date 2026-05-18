import Foundation

protocol CustomerNoteServiceProtocol: Sendable {
    func getNotes(customerId: String) async throws -> [CustomerNote]
    func createNote(customerId: String, text: String, isTask: Bool) async throws -> Bool
    func updateNote(noteId: String, text: String, isTask: Bool, isResolved: Bool) async throws -> Bool
    func deleteNote(noteId: String) async throws -> Bool
}

final class CustomerNoteService: CustomerNoteServiceProtocol, @unchecked Sendable {
    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = .shared, baseURL: URL = APIConfig.baseUrl) {
        self.session = session
        self.baseURL = baseURL
    }

    func getNotes(customerId: String) async throws -> [CustomerNote] {
        let url = baseURL.appendingPathComponent("Customer/\(customerId)/notes")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        injectToken(into: &request)

        let (data, response) = try await session.data(for: request)
        guard response is HTTPURLResponse else { throw AppError.unknown }
        return try data.decodeBaseResponse()
    }

    func createNote(customerId: String, text: String, isTask: Bool) async throws -> Bool {
        let url = baseURL.appendingPathComponent("Customer/\(customerId)/notes")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        injectToken(into: &request)
        
        let body = AddNoteRequest(text: text, isTask: isTask)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard response is HTTPURLResponse else { throw AppError.unknown }
        return try data.decodeBaseResponse()
    }

    func updateNote(noteId: String, text: String, isTask: Bool, isResolved: Bool) async throws -> Bool {
        let url = baseURL.appendingPathComponent("Customer/notes/\(noteId)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        injectToken(into: &request)
        
        let body = UpdateNoteRequest(text: text, isTask: isTask, isResolved: isResolved)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard response is HTTPURLResponse else { throw AppError.unknown }
        return try data.decodeBaseResponse()
    }

    func deleteNote(noteId: String) async throws -> Bool {
        let url = baseURL.appendingPathComponent("Customer/notes/\(noteId)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        injectToken(into: &request)

        let (data, response) = try await session.data(for: request)
        guard response is HTTPURLResponse else { throw AppError.unknown }
        return try data.decodeBaseResponse()
    }

    private func injectToken(into request: inout URLRequest) {
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
