import Foundation
import Combine
import SwiftUI
import SignalRClient

@MainActor
final class ChatDetailViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var currentMessage = ""
    @Published var isLoading = false

    private let chatService: ChatServiceProtocol
    let chatId: String

    private static let timeFormatStyle: Date.FormatStyle = .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)
    
    private var hubConnection: HubConnection?

    init(chatId: String, chatService: ChatServiceProtocol? = nil) {
        self.chatId = chatId
        self.chatService = chatService ?? ChatService()
    }

    func fetchMessages() async {
        guard !chatId.isEmpty && !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedMessages = try await chatService.getMessages(customerId: chatId)
            self.messages = fetchedMessages
            
            let hasUnreadMessages = fetchedMessages.contains { message in
                return !message.isSentByMe && !message.isReadByMe
            }
            
            if hasUnreadMessages {
                do {
                    try await chatService.updateMessagesStatus(customerId: chatId, status: .read)
                    print("Status atualizado. Mensagens marcadas como lidas!")
                } catch {
                    print("ERRO AO ATUALIZAR STATUS: \(error)")
                }
            }
            
            setupSignalR()
            
        } catch {
            print("Erro ao buscar histórico: \(error)")
        }
    }

    func sendMessage() async {
        let textToSend = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return }

        let myId = AuthManager.shared.userId ?? "me"
        let timestamp = Date().formatted(Self.timeFormatStyle)
        
        let newMessage = Message(
            id: UUID().uuidString,
            text: textToSend,
            timestamp: timestamp,
            isSentByMe: true,
            isReadByMe: true,
            senderId: myId
        )

        messages.append(newMessage)
        currentMessage = ""

        do {
            try await chatService.sendMessage(
                customerId: chatId,
                text: textToSend
            )
        } catch {
            print("Erro ao enviar: \(error)")
        }
    }

    private func setupSignalR() {
        _ = UserDefaults.standard.string(forKey: "user_token") ?? ""
        
        hubConnection?.on(method: "ReceiveNewMessage") { [weak self] (argumentExtractor) in
            do {
                let incomingMessage = try argumentExtractor.getArgument(type: Message.self)
                
                Task { @MainActor in
                    if !(self?.messages.contains(where: { $0.id == incomingMessage.id }) ?? false) {
                        self?.messages.append(incomingMessage)
                    }
                }
            } catch {
                print("Erro ao decodificar: \(error)")
            }
        }
        
        hubConnection?.start()
    }
    
    func stopSignalR() {
        hubConnection?.stop()
    }
}

struct EventsAndChatsView: View {
    @Binding var selectedTab: BottomNavBar.Tab
    
    @Binding var chatDetailPath: NavigationPath

    var body: some View {
        NavigationStack(path: $chatDetailPath) {
            ChatsScreen(chatDetailPath: $chatDetailPath)
                .navigationDestination(for: ChatDetailRoute.self) { route in
                    ChatDetailScreen(
                        chatId: route.chatId,
                        participantName: route.participantName,
                        participantAvatarUrl: route.participantAvatarUrl
                    )
                }
        }
    }
}

