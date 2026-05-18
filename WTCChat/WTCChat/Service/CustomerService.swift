import Foundation

protocol CustomerServiceProtocol: Sendable {
    func fetchCustomers(query: String?) async throws -> [Customer]
    func getProfile360(id: String) async throws -> Profile360Response
}

final class CustomerService: CustomerServiceProtocol, @unchecked Sendable {
    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = .shared, baseURL: URL = APIConfig.baseUrl) {
        self.session = session
        self.baseURL = baseURL
    }

    func fetchCustomers(query: String?) async throws -> [Customer] {
        let fullURL = baseURL.appendingPathComponent(APIConfig.Endpoints.customerSearch)
        var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: true)
        
        if let query = query, !query.isEmpty {
            components?.queryItems = [URLQueryItem(name: "search", value: query)]
        }

        guard let url = components?.url else {
            throw AppError.businessError("URL de busca inválida")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "user_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard response is HTTPURLResponse else {
            throw AppError.unknown
        }

        return try data.decodeBaseResponse()
    }
    
    func getProfile360(id: String) async throws -> Profile360Response {
        let fullURL = baseURL.appendingPathComponent("Customer/\(id)/profile360")
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AppError.unknown
        }

        return try data.decodeBaseResponse()
    }
    
    func updateCustomerCrm(customerId: String, score: Int?, status: String?, segmentId: String?) async throws -> Bool {
            let url = baseURL.appendingPathComponent("Customer/\(customerId)/crm")
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let token = TokenManager.shared.getToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let body = UpdateCrmRequest(score: score, status: status, segmentId: segmentId)
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    _ = String(data: data, encoding: .utf8) ?? "Corpo vazio"
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { throw AppError.unknown }
            
            return (200...299).contains(httpResponse.statusCode)
        }
}
