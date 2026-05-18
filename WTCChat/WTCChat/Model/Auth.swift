import Foundation

// MARK: - Login
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthContent: Codable {
    let id: String
    let token: String
    let name: String
    let role: String
    let imageUrl: String?
}

struct UserDto: Codable {
    let id: String
    let name: String
    let email: String
    let role: String
    let profileImageKey: String?
    
    var imageUrl: String? { profileImageKey }
}


// MARK: - Register
struct SignUpRequest: Codable {
    let email: String
    let documentId: String
    let password: String
    let confirmPassword: String
    let name: String
}
