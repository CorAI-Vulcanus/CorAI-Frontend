import Foundation

protocol RecordingRepositoryProtocol: Sendable {
    func ingestECG(userId: String, payload: SensorDataPayload) async throws
}

final class RecordingRepository: RecordingRepositoryProtocol {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }

    func ingestECG(userId: String, payload: SensorDataPayload) async throws {
        try await client.requestEmpty(.ingestECG(userId: userId), body: payload)
    }
}
