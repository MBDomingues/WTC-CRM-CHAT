import Foundation
import UIKit
import Combine

@MainActor
class CreateGroupViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var groupDescription: String = ""
    @Published var selectedImage: UIImage? = nil
    
    @Published var selectedMemberIds: Set<String> = []
    @Published var allCustomers: [Customer] = []
    
    @Published var isLoading: Bool = false
    
    @Published var popup: PopupData? = nil

    private let customerService = CustomerService()

    func fetchCustomers() async {
        do {
            self.allCustomers = try await customerService.fetchCustomers(query: "")
        } catch {
            self.allCustomers = []
        }
    }

    func createGroup() async -> Bool {
        guard !groupName.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.popup = PopupData(type: .error, title: "Atenção", message: "O nome do grupo é obrigatório.")
            return false
        }
        
        isLoading = true
        
        do {
            let url = APIConfig.baseUrl.appendingPathComponent(APIConfig.Endpoints.messages)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let token = UserDefaults.standard.string(forKey: "user_token") ?? ""
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            body.append(convertFormField(named: "Name", value: groupName, using: boundary))
            
            if !groupDescription.isEmpty {
                body.append(convertFormField(named: "Description", value: groupDescription, using: boundary))
            }
            
            for id in selectedMemberIds {
                body.append(convertFormField(named: "MemberIds", value: id, using: boundary))
            }
            
            if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.7) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"Image\"; filename=\"group_profile.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                isLoading = false
                return false
            }
            
            if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
                isLoading = false
                self.popup = PopupData(type: .success, title: "Sucesso!", message: "O grupo foi criado e os participantes foram adicionados.")
                return true
            } else {
                isLoading = false
                self.popup = PopupData(type: .error, title: "Atenção", message: "Não foi possível criar o grupo. Verifique os dados e tente novamente.")
                return false
            }
            
        } catch {
            isLoading = false
            self.popup = PopupData(type: .error, title: "Sem Conexão", message: "Ocorreu um erro de rede. Verifique sua internet.")
            return false
        }
    }
    
    private func convertFormField(named name: String, value: String, using boundary: String) -> Data {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
        fieldString += "\(value)\r\n"
        return fieldString.data(using: .utf8)!
    }
}
