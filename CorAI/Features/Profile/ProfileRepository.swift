import Foundation

final class ProfileRepository {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }

    func fetchProfile(userId: String) async throws -> UserProfile {
        return try await client.request(.getUser(userId: userId), body: nil)
    }

    func updateProfile(userId: String, name: String?, email: String?, phone: String?) async throws {
        struct UpdateBody: Encodable {
            let name: String?
            let email: String?
            let phone: String?
        }
        try await client.requestEmpty(
            .updateUser(userId: userId),
            body: UpdateBody(name: name, email: email, phone: phone)
        )
    }
}
