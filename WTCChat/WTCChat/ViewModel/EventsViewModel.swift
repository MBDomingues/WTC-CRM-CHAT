import Foundation
import Combine

@MainActor
class EventsViewModel: ObservableObject {
    @Published var eventos: [AnnouncementItem] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    
    @Published var currentPage = 1
    @Published var hasMore = true
    private let pageSize = 10

    var filteredEventos: [AnnouncementItem] {
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return eventos
        }
        return eventos.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.description.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    func fetchAnnouncements(isRefresh: Bool = false) async {
        if isRefresh {
            currentPage = 1
            hasMore = true
        }
        
        guard hasMore else { return }
        guard !isLoading else { return }
        
        isLoading = true
        
        var urlComponents = URLComponents(url: APIConfig.baseUrl.appendingPathComponent(APIConfig.Endpoints.announcementsFeed), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(currentPage)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "user_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decoded = try JSONDecoder().decode(AnnouncementBaseResponse.self, from: data)
                
                if decoded.isSuccess {
                    let novosEventos = decoded.content ?? []
                    
                    if isRefresh {
                        self.eventos = novosEventos
                    } else {
                        self.eventos.append(contentsOf: novosEventos)
                    }
                    
                    if novosEventos.count < pageSize {
                        self.hasMore = false
                    }
                    
                    self.currentPage += 1
                }
            }
        } catch {
            print("Erro ao buscar eventos: \(error)")
        }
        
        isLoading = false
    }
}
