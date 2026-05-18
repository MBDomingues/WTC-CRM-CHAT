import Foundation

enum Route: Hashable {
    case home
    case login
    case signUp
    case chats
    case chatDetail(chatId: Int)
    case config
    case events
    case announce
    case select
}
