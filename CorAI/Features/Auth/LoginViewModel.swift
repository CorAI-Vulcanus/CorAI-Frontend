import Foundation

@Observable
final class LoginViewModel {
    var username     = ""
    var password     = ""
    var isLoading    = false
    var errorMessage: String?

    // Sign-in form fields (registro)
    var signInName   = ""
    var signInEmail  = ""
    var signInPhone  = ""
    var signInRole   = "Patient"

    private let repository: AuthRepositoryProtocol
    private let session: SessionManager

    init(
        repository: AuthRepositoryProtocol = AuthRepository(),
        session: SessionManager = .shared
    ) {
        self.repository = repository
        self.session    = session
    }

    // MARK: - Login

    func login() async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Ingresa usuario y contraseña."
            return
        }
        isLoading    = true
        errorMessage = nil
        do {
            let response = try await repository.login(username: username, password: password)
            let userId   = session.extractUserId(from: response.token) ?? ""
            session.save(token: response.token, userId: userId)
        } catch NetworkError.unauthorized {
            errorMessage = "Usuario o contraseña incorrectos."
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Register

    func signIn() async {
        guard !username.isEmpty, !password.isEmpty,
              !signInEmail.isEmpty, !signInPhone.isEmpty else {
            errorMessage = "Completa todos los campos."
            return
        }
        isLoading    = true
        errorMessage = nil
        do {
            let req = SignInRequest(
                user_name:    username,
                password:     password,
                name:         signInName,
                email:        signInEmail,
                phone_number: signInPhone,
                role:         signInRole
            )
            try await repository.signIn(req)
            // Auto-login después de registrarse
            await login()
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
