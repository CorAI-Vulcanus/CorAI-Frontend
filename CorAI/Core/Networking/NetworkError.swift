import Foundation

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case noData
    case unauthorized
    case serverError(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .requestFailed(let code):
            return "Request failed with status code \(code)."
        case .decodingFailed:
            return "Failed to decode the response."
        case .noData:
            return "No data received."
        case .unauthorized:
            return "Unauthorized access."
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
