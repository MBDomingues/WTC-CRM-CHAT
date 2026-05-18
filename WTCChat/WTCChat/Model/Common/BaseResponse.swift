struct BaseResponse<T: Codable>: Codable {
    let isSuccess: Bool
    let errorMessage: String?
    let content: T?
}
