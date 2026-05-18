import Foundation
import SwiftUI
import Combine

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    
    @Published var popup: PopupData? = nil
    
    @Published var documentId: String = "" {
        didSet {
            let filtered = documentId.filter { $0.isNumber }
            
            if filtered.count > 11 {
                documentId = oldValue
                return
            }
            
            let maskedValue = formatCPF(filtered)
            
            if documentId != maskedValue {
                DispatchQueue.main.async {
                    self.documentId = maskedValue
                }
            }
        }
    }

    // MARK: - Validação de Formulário
    private func validateForm() -> Bool {
        if name.trimmingCharacters(in: .whitespaces).count < 3 {
            self.popup = PopupData(type: .error, title: "Atenção", message: "O nome deve ter pelo menos 3 caracteres.")
            return false
        }
        
        if !email.isValidEmail {
            self.popup = PopupData(type: .error, title: "Atenção", message: "Insira um e-mail válido.")
            return false
        }
        
        if !documentId.isValidCPF {
            self.popup = PopupData(type: .error, title: "Atenção", message: "O CPF informado é inválido.")
            return false
        }
        
        if password.count < 6 {
            self.popup = PopupData(type: .error, title: "Atenção", message: "A senha deve ter no mínimo 6 caracteres.")
            return false
        }
        
        if password != confirmPassword {
            self.popup = PopupData(type: .error, title: "Atenção", message: "As senhas não coincidem.")
            return false
        }
        
        return true
    }

    func signUp() async {
        guard validateForm() else { return }

        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDocument = documentId.filter { $0.isNumber }

        isLoading = true
        popup = nil
        defer { isLoading = false }

        do {
            let request = SignUpRequest(
                email: cleanedEmail,
                documentId: cleanDocument,
                password: password,
                confirmPassword: confirmPassword,
                name: cleanedName
            )
            
            let response = try await authService.register(request: request)
            onSignUpSuccess?(response)
            
        } catch let error as AppError {
            self.popup = PopupData(type: .error, title: "Erro no Cadastro", message: error.errorDescription ?? error.localizedDescription)
        } catch {
            self.popup = PopupData(type: .error, title: "Sem Conexão", message: "Erro ao conectar com o servidor.")
        }
    }

    // MARK: - Helper de Máscara
    private func formatCPF(_ numbers: String) -> String {
        var result = ""
        let characters = Array(numbers)
        
        for i in 0..<characters.count {
            if i == 3 || i == 6 {
                result.append(".")
            } else if i == 9 {
                result.append("-")
            }
            result.append(characters[i])
        }
        return result
    }

    private let authService: AuthServiceProtocol
    var onSignUpSuccess: ((AuthContent) -> Void)?

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
    }
}
