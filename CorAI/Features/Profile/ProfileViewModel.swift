import Foundation

@Observable
final class ProfileViewModel {
    var profile: UserProfile?
    var isLoading    = false
    var isSaving     = false
    var errorMessage: String?
    var successMessage: String?

    // Edit state
    var editName:  String = ""
    var editEmail: String = ""
    var editPhone: String = ""
    var isEditing  = false

    private let repository = ProfileRepository()
    private let session    = SessionManager.shared

    // MARK: - Load

    func load() async {
        isLoading    = true
        errorMessage = nil
        do {
            profile    = try await repository.fetchProfile(userId: session.userId)
            editName   = profile?.name  ?? ""
            editEmail  = profile?.email ?? ""
            editPhone  = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Save

    func saveChanges() async {
        isSaving       = true
        errorMessage   = nil
        successMessage = nil
        do {
            try await repository.updateProfile(
                userId: session.userId,
                name:   editName.isEmpty  ? nil : editName,
                email:  editEmail.isEmpty ? nil : editEmail,
                phone:  editPhone.isEmpty ? nil : editPhone
            )
            successMessage = "Perfil actualizado."
            isEditing      = false
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    // MARK: - Logout

    func logout() {
        session.logout()
    }

    // MARK: - Helpers

    var roleLabel: String {
        switch profile?.role {
        case "Doctor":  return "Doctor"
        case "Admin":   return "Administrador"
        default:        return "Paciente"
        }
    }

    var initials: String {
        guard let name = profile?.name, !name.isEmpty else {
            return profile?.username.prefix(2).uppercased() ?? "?"
        }
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }
}
