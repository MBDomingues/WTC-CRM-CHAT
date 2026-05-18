import Combine
import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    
    @Published var filteredChats: [Chat] = []
    
    @Published var searchText: String = "" {
        didSet {
            filterChatsLocally()
        }
    }
    
    @Published var isLoading = false

    private let chatService: ChatServiceProtocol

    init(chatService: ChatServiceProtocol? = nil) {
        self.chatService = chatService ?? ChatService()
    }


    func fetchChats() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedChats = try await chatService.getChats()
            self.chats = fetchedChats
            self.filterChatsLocally()
            
        } catch {
            if (error as NSError).code == NSURLErrorCancelled {
                return
            }
            
            self.chats = []
            self.filteredChats = []
        }
    }
    
    private func filterChatsLocally() {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            filteredChats = chats
        } else {
            filteredChats = chats.filter { chat in
                chat.senderName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
