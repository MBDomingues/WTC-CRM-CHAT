import SwiftUI
import PhotosUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var imageUrl: String? = nil
    @Published var isLoading = false
    @Published var selectedItem: PhotosPickerItem? = nil
    
    @Published var popup: PopupData? = nil

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
    }

    func uploadPhoto(item: PhotosPickerItem?, authManager: AuthManager) async {
        guard let item = item else { return }

        isLoading = true
        popup = nil
        defer { isLoading = false }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                let response = try await authService.updateProfilePhoto(image: uiImage)
                
                self.imageUrl = response.imageUrl
                authManager.userImageUrl = response.imageUrl
                UserDefaults.standard.set(response.imageUrl, forKey: "user_image_url")
                
                self.popup = PopupData(type: .success, title: "Sucesso!", message: "Sua foto de perfil foi atualizada com sucesso.")
            }
        } catch let error as AppError {
            switch error {
            case .businessError(let message):
                self.popup = PopupData(type: .error, title: "Atenção", message: message)
            default:
                self.popup = PopupData(type: .error, title: "Erro", message: "Erro ao processar imagem.")
            }
        } catch {
            self.popup = PopupData(type: .error, title: "Sem Conexão", message: "Não foi possível conectar ao servidor.")
        }
    }
}
