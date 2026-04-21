import Foundation

@Observable
final class DoctorViewModel {
    var patients:     [PatientSummary] = []
    var isLoading     = false
    var errorMessage: String?
    var searchText    = ""

    private let repository = DoctorRepository()

    var filtered: [PatientSummary] {
        guard !searchText.isEmpty else { return patients }
        return patients.filter { p in
            p.id.localizedCaseInsensitiveContains(searchText) ||
            (p.user_id.localizedCaseInsensitiveContains(searchText))
        }
    }

    func load() async {
        isLoading    = true
        errorMessage = nil
        do {
            patients = try await repository.fetchPatients()
        } catch NetworkError.unauthorized {
            errorMessage = "No tienes permiso para ver pacientes."
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
