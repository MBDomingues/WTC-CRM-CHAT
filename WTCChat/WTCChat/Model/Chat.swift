import Foundation
import SwiftUI

struct Chat: Codable, Identifiable {
    let id: String
    let senderName: String
    let lastMessage: String
    let timestamp: String
    let profilePicUrl: String?
    let isRead: Bool
    let isGroup: Bool
    
    var lastMessageStatus: MessageStatus? = .sent
    var isLastMessageMine: Bool? = false
}

struct SendMessageRequest: Codable {
    let text: String
}

enum MessageStatus: String, Codable {
    case sent = "Sent"
    case delivered = "Delivered"
    case read = "Read"
    case failed = "Failed"
    
    var iconName: String {
        switch self {
        case .sent: return "checkmark"
        case .delivered, .read: return "checkmark.double"
        case .failed: return "exclamationmark.circle"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .read: return .blue
        case .failed: return .red
        default: return .cinza //
        }
    }
}

struct Message: Codable, Identifiable, Equatable {
    let id: String
    let text: String
    let timestamp: String
    let isSentByMe: Bool
    let isReadByMe: Bool
    
    var senderId: String? = nil
    var title: String? = nil
    var url: String? = nil
    var actions: [MessageAction]? = nil
    var actionUrls: [String: String]? = nil
    var senderName: String? = nil
    var senderPhotoUrl: String? = nil
    var status: MessageStatus? = .sent
}

struct MessageAction: Codable, Hashable {
    let action: String
    let title: String
}

struct ChatDetailRoute: Hashable {
    let chatId: String
    let participantName: String
    let participantAvatarUrl: String
}
