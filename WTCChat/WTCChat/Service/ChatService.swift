import Foundation

protocol ChatServiceProtocol: Sendable {
    func getMessages(customerId: String) async throws -> [Message]
    func sendMessage(customerId: String, text: String) async throws
    func getChats() async throws -> [Chat]
    func updateMessagesStatus(customerId: String, status: MessageStatus) async throws
}

final class ChatService: ChatServiceProtocol, @unchecked Sendable {
    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = .shared, baseURL: URL = APIConfig.baseUrl) {
        self.session = session
        self.baseURL = baseURL
    }

    func getMessages(customerId: String) async throws -> [Message] {
        let url = baseURL.appendingPathComponent("Messages/\(customerId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        injectToken(into: &request)

        let (data, response) = try await session.data(for: request)
        guard response is HTTPURLResponse else { throw AppError.unknown }
        
        return try data.decodeBaseResponse()
    }
    
    func updateMessagesStatus(customerId: String, status: MessageStatus) async throws {
        let url = baseURL.appendingPathComponent("Messages/\(customerId)/status")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        injectToken(into: &request)
        
        let body: [String: Any] = ["status": status.rawValue]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.unknown
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            _ = String(data: data, encoding: .utf8) ?? "Sem detalhes"
            throw AppError.businessError("Erro \(httpResponse.statusCode)")
        }
    }
    
    func getChats() async throws -> [Chat] {
        let url = baseURL.appendingPathComponent("Messages/chats")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        injectToken(into: &request)

        let (data, response) = try await session.data(for: request)
        guard response is HTTPURLResponse else { throw AppError.unknown }
        
        return try data.decodeBaseResponse()
    }

    func sendMessage(customerId: String, text: String) async throws {
        let url = baseURL.appendingPathComponent("Messages/\(customerId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        injectToken(into: &request)
        
        let body: [String: Any] = [
            "text": text
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw AppError.unknown }
        
        guard (200...299).contains(httpResponse.statusCode) else {
             throw AppError.businessError("Falha ao enviar mensagem (Status \(httpResponse.statusCode))")
        }
        
    }

    private func injectToken(into request: inout URLRequest) {
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
