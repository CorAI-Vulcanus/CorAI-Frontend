import Foundation

// MARK: - Protocol

protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint, body: Encodable?) async throws -> T
    func requestEmpty(_ endpoint: Endpoint, body: Encodable?) async throws
}

// MARK: - Live Implementation

final class APIClient: APIClientProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint, body: Encodable? = nil) async throws -> T {
        let urlRequest = try buildRequest(endpoint: endpoint, body: body)
        let (data, response) = try await session.data(for: urlRequest)
        try validate(response: response, data: data)
        return try decode(T.self, from: data)
    }

    func requestEmpty(_ endpoint: Endpoint, body: Encodable? = nil) async throws {
        let urlRequest = try buildRequest(endpoint: endpoint, body: body)
        let (data, response) = try await session.data(for: urlRequest)
        try validate(response: response, data: data)
    }

    // MARK: - Private

    private func buildRequest(endpoint: Endpoint, body: Encodable?) throws -> URLRequest {
        guard let url = endpoint.url else { throw NetworkError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = endpoint.method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainManager.shared.loadToken() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }

        return req
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        switch http.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            let msg = (try? JSONDecoder().decode(BackendError.self, from: data))?.detail
            throw NetworkError.requestFailed(statusCode: http.statusCode, message: msg)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

// MARK: - Backend error envelope

private struct BackendError: Decodable {
    let detail: String?
}
