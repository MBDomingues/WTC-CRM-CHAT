import Foundation

enum AppError: Error, LocalizedError {
    case businessError(String)
    case decodingError
    case networkError(Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .businessError(let message): return message
        case .decodingError: return "Houve um problema ao processar os dados."
        case .networkError(let code): return "Erro no servidor (Código: \(code))."
        case .unknown: return "Erro inesperado."
        }
    }
}
