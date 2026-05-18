import Foundation

class TokenManager {
    static let shared = TokenManager()
    static let userTokenKey = "user_jwt_token"

    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: TokenManager.userTokenKey)
    }

    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: TokenManager.userTokenKey)
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: TokenManager.userTokenKey)
    }
    
    var isLoggedIn: Bool {
        return getToken() != nil
    }
}
