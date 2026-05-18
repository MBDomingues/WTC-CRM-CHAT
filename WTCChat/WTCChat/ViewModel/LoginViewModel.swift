import Foundation
import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    
    @Published var popup: PopupData? = nil

    private let authService: AuthServiceProtocol

    var onLoginSuccess: ((AuthContent) -> Void)?

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
    }

    func login() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty, !trimmedPass.isEmpty else {
            self.popup = PopupData(type: .error, title: "Atenção", message: "Por favor, preencha e-mail e senha.")
            return
        }

        isLoading = true
        popup = nil
        
        defer { isLoading = false }

        do {
            let request = LoginRequest(email: trimmedEmail, password: trimmedPass)
            let response = try await authService.login(request: request)
            
            onLoginSuccess?(response)
            
        } catch let error as AppError {
            self.popup = PopupData(type: .error, title: "Ops!", message: error.errorDescription ?? error.localizedDescription)
        } catch is DecodingError {
            self.popup = PopupData(type: .error, title: "Erro interno", message: "Erro ao processar dados do servidor.")
        } catch {
            self.popup = PopupData(type: .error, title: "Sem Conexão", message: "Falha na conexão. Tente novamente.")
        }
    }
}
