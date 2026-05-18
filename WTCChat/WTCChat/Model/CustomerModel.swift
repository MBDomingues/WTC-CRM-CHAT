struct Customer: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let imageUrl: String?
}

struct UpdateCrmRequest: Codable {
    let score: Int?
    let status: String?
    let segmentId: String?
}
