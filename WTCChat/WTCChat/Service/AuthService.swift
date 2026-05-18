import Foundation
import UIKit

protocol AuthServiceProtocol: Sendable {
    func login(request: LoginRequest) async throws -> AuthContent
    func register(request: SignUpRequest) async throws -> AuthContent
    func updateProfilePhoto(image: UIImage) async throws -> UpdatePhotoResponse
}

final class AuthService: AuthServiceProtocol, @unchecked Sendable {
    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = .shared, baseURL: URL = APIConfig.baseUrl) {
        self.session = session
        self.baseURL = baseURL
    }

    func login(request: LoginRequest) async throws -> AuthContent {
        let authContent: AuthContent = try await post(path: APIConfig.Endpoints.login, body: request)
    
        TokenManager.shared.saveToken(authContent.token)
        
        return authContent
    }

    func register(request: SignUpRequest) async throws -> AuthContent {
        let authContent: AuthContent = try await post(path: APIConfig.Endpoints.register, body: request)
        
        TokenManager.shared.saveToken(authContent.token)
        
        return authContent
    }

    func updateProfilePhoto(image: UIImage) async throws -> UpdatePhotoResponse {
        try await patchMultipart(path: APIConfig.Endpoints.updatePhoto, image: image)
    }

    // MARK: - Helpers (JSON)
    private func post<T: Codable, Body: Encodable>(path: String, body: Body) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        return try await performRequest(request)
    }

    // MARK: - Multipart Helper
    private func patchMultipart<T: Codable>(path: String, image: UIImage) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw AppError.decodingError
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        let (data, _) = try await session.upload(for: request, from: body)
        return try data.decodeBaseResponse()
    }

    private func performRequest<T: Codable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        
        guard response is HTTPURLResponse else {
            throw AppError.unknown
        }
        
        return try data.decodeBaseResponse()
    }
}

extension Data {
    func decodeBaseResponse<T: Codable>() throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let baseResponse = try? decoder.decode(BaseResponse<T>.self, from: self) else {
            throw AppError.decodingError
        }

        if baseResponse.isSuccess {
            if let safeData = baseResponse.content {
                return safeData
            } else {
                if let boolValue = true as? T { return boolValue }
                throw AppError.decodingError
            }
        } else {
            throw AppError.businessError(baseResponse.errorMessage ?? "Erro desconhecido")
        }
    }
}
