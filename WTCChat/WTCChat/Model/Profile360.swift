import Foundation

struct Profile360Response: Codable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let photoUrl: String?
    let status: String?
    let score: Int?
    let segmentId: String?
    let notesAndTasks: [NoteSnapshot]
    let recentMessages: [MessageSnapshot]
    let recentCampaigns: [CampaignSnapshot]
}

struct NoteSnapshot: Codable, Identifiable {
    let id: String
    let text: String
    let operatorName: String
    let createdAt: Date
    let isTask: Bool
    let isResolved: Bool
}

struct MessageSnapshot: Codable, Identifiable {
    let id: String
    let text: String
    let isFromOperator: Bool
    let createdAt: Date
}

struct CampaignSnapshot: Codable, Identifiable {
    let id: String
    let title: String
    let sentAt: Date
}
