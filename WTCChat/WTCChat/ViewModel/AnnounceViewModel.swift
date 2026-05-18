import SwiftUI
import PhotosUI
import Combine

@MainActor
class AnnounceViewModel: ObservableObject {

    @Published var titulo = ""
    @Published var dataEvento = Date()
    @Published var local = ""
    @Published var descricao = ""
    @Published var destinatarios: [Destinatario] = []
    @Published var isLoadingDestinatarios = false
    @Published var popup: PopupData? = nil

    @Published var availableSegments: [Segment] = []
    @Published var selectedSegmentIds: Set<String> = []
    
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet { Task { await loadImage() } }
    }
    @Published var selectedImage: UIImage? = nil
    @Published var isSending = false
    
    private let baseURL = APIConfig.baseUrl

    private func loadImage() async {
        guard let item = selectedItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
            self.selectedImage = uiImage
        }
    }

    func fetchSegments() async {
        do {
            self.availableSegments = try await SegmentService().getSegments()
        } catch {
            print("Erro ao buscar segmentos: \(error)")
        }
    }

    func fetchDestinatarios(search: String? = nil, segmentIds: Set<String> = []) async {
        isLoadingDestinatarios = true
        defer { isLoadingDestinatarios = false }
        
        struct RecipientDTO: Decodable {
            let id: String
            let name: String
            let imageUrl: String?
            let isGroup: Bool
            let segmentId: String?
        }
        
        struct ResponseDTO: Decodable {
            let content: [RecipientDTO]?
            let isSuccess: Bool
        }
        
        let url = baseURL.appendingPathComponent(APIConfig.Endpoints.announceRecipients)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        var queryItems: [URLQueryItem] = []

        for id in segmentIds {
            queryItems.append(URLQueryItem(name: "segmentIds", value: id))
        }
        
        if let search = search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let finalURL = components.url else { return }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decoded = try JSONDecoder().decode(ResponseDTO.self, from: data)
                
                if decoded.isSuccess {
                    let jsonArray = decoded.content ?? []
                    self.destinatarios = jsonArray.map { dto in
                        Destinatario(
                            id: dto.id,
                            nome: dto.name,
                            imagemUrl: dto.imageUrl ?? "",
                            isGroup: dto.isGroup,
                            segmentId: dto.segmentId,
                            selecionado: false
                        )
                    }
                }
            }
        } catch {
            print("Erro ao decodificar destinatários: \(error)")
        }
    }

    func sendAnnouncement(recipientIds: [String]) async {
        isSending = true
        defer { isSending = false }
        
        let url = baseURL.appendingPathComponent("Announce/announce")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "user_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = createMultipartBody(boundary: boundary, recipientIds: recipientIds)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode == 200 {
                self.popup = PopupData(type: .success, title: "Sucesso!", message: "O anúncio foi disparado com sucesso para os destinatários selecionados.")
            } else {
                self.popup = PopupData(type: .error, title: "Atenção", message: "Não foi possível enviar o anúncio. Verifique os dados e tente novamente.")
            }
        } catch {
            self.popup = PopupData(type: .error, title: "Sem Conexão", message: "Ocorreu um erro de rede. Verifique sua internet.")
        }
    }
    
    private func createMultipartBody(boundary: String, recipientIds: [String]) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy 'às' HH:mm"
        let dataString = formatter.string(from: dataEvento)
        
        let parameters = [
            "Title": titulo,
            "Date": dataString,
            "Location": local,
            "Description": descricao
        ]
        
        for (key, value) in parameters {
            body.append(Data(boundaryPrefix.utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            body.append(Data("\(value)\r\n".utf8))
        }
        
        for id in recipientIds {
            body.append(Data(boundaryPrefix.utf8))
            body.append(Data("Content-Disposition: form-data; name=\"RecipientIds\"\r\n\r\n".utf8))
            body.append(Data("\(id)\r\n".utf8))
        }
        
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.7) {
            body.append(Data(boundaryPrefix.utf8))
            body.append(Data("Content-Disposition: form-data; name=\"Image\"; filename=\"poster.jpg\"\r\n".utf8))
            body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
            body.append(imageData)
            body.append(Data("\r\n".utf8))
        }
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }
}
