import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int, message: String?)
    case decodingFailed
    case noData
    case unauthorized
    case serverError(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida."
        case .requestFailed(let code, let msg):
            return msg ?? "Error \(code)."
        case .decodingFailed:
            return "Error al decodificar respuesta."
        case .noData:
            return "Sin datos."
        case .unauthorized:
            return "Sesión expirada. Inicia sesión nuevamente."
        case .serverError(let m):
            return "Error del servidor: \(m)"
        case .unknown(let e):
            return e.localizedDescription
        }
    }
}
