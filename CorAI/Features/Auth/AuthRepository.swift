import Foundation

protocol AuthRepositoryProtocol: Sendable {
    func login(username: String, password: String) async throws -> LoginResponse
    func signIn(_ request: SignInRequest) async throws
    func getUser(userId: String) async throws -> UserProfile
}

final class AuthRepository: AuthRepositoryProtocol {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }

    func login(username: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(user_name: username, password: password)
        return try await client.request(.login, body: body)
    }

    func signIn(_ request: SignInRequest) async throws {
        try await client.requestEmpty(.signIn, body: request)
    }

    func getUser(userId: String) async throws -> UserProfile {
        return try await client.request(.getUser(userId: userId), body: nil)
    }
}
