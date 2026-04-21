import Foundation

// GET /patients response item
struct PatientSummary: Decodable, Identifiable, Hashable {
    let id: String
    let user_id: String
    let blood_type: String?
    let sex: String?
    let weight: Double?
    let height: Double?
}

// GET /patient/{user_id} detailed response (reuses backend shape)
struct PatientDetail: Decodable {
    let id: String
    let user_id: String
    let username: String?
    let name: String?
    let email: String?
    let blood_type: String?
    let sex: String?
    let weight: Double?
    let height: Double?
}

final class DoctorRepository {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }

    func fetchPatients() async throws -> [PatientSummary] {
        return try await client.request(.getPatients, body: nil)
    }

    func fetchPatientDetail(userId: String) async throws -> PatientDetail {
        return try await client.request(.getPatient(userId: userId), body: nil)
    }
}
