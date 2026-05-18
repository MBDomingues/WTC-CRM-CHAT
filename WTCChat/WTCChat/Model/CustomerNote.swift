import Foundation

struct CustomerNote: Codable, Identifiable, Hashable {
    let id: String
    let customerId: String
    let operatorId: String
    let text: String
    let isTask: Bool
    let isResolved: Bool
    let createdAt: Date
    let updatedAt: Date?
}

struct AddNoteRequest: Codable {
    let text: String
    let isTask: Bool
}

struct UpdateNoteRequest: Codable {
    let text: String
    let isTask: Bool
    let isResolved: Bool
}
