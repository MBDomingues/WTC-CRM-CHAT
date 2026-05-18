enum TipoDestinatario {
    case pessoa, grupo
}

struct Destinatario: Identifiable {
    let id: String
    let nome: String
    let imagemUrl: String
    let isGroup: Bool
    var segmentId: String?
    var selecionado: Bool
}

struct AnnouncementItem: Identifiable, Decodable {
    let id: String
    let title: String
    let description: String
    let date: String
    let location: String
    let imageUrl: String?
    let createdAt: String
}

struct AnnouncementBaseResponse: Decodable {
    let content: [AnnouncementItem]?
    let isSuccess: Bool
    let errorMessage: String?
}
