import Foundation
import Combine

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var isAdmin: Bool = false
    @Published var userName: String = ""
    @Published var userImageUrl: String? = nil
    @Published var userId: String?
    
    private let tokenKey = "user_token"
    private let idKey = "user_id"
    private let roleKey = "user_role"
    private let nameKey = "user_name"
    private let imgKey = "user_image_url"
    
    init() {
        checkAuthStatus()
    }

    func login(content: AuthContent) {
        UserDefaults.standard.set(content.id, forKey: idKey)
        UserDefaults.standard.set(content.token, forKey: tokenKey)
        UserDefaults.standard.set(content.role, forKey: roleKey)
        UserDefaults.standard.set(content.name, forKey: nameKey)
        UserDefaults.standard.set(content.imageUrl, forKey: imgKey)
        
        updateUI(
            id: content.id,
            role: content.role,
            name: content.name,
            img: content.imageUrl
        )
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: idKey)
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: roleKey)
        UserDefaults.standard.removeObject(forKey: nameKey)
        UserDefaults.standard.removeObject(forKey: imgKey)
        
        isAuthenticated = false
        userId = nil
        userName = ""
        userImageUrl = nil
        isAdmin = false
    }

    private func checkAuthStatus() {
        if let token = UserDefaults.standard.string(forKey: tokenKey), !token.isEmpty {
            let id = UserDefaults.standard.string(forKey: idKey)
            let role = UserDefaults.standard.string(forKey: roleKey) ?? "User"
            let name = UserDefaults.standard.string(forKey: nameKey) ?? "Usuário"
            let img = UserDefaults.standard.string(forKey: imgKey)
            
            updateUI(id: id, role: role, name: name, img: img)
        }
    }

    private func updateUI(id: String?, role: String, name: String, img: String? = nil) {
        self.userId = id
        self.isAdmin = (role.lowercased() == "admin")
        self.userName = name
        self.userImageUrl = img
        self.isAuthenticated = true
    }
}
