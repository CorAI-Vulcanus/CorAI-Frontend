import Foundation

@Observable
final class SessionManager {
    static let shared = SessionManager()

    private(set) var isLoggedIn: Bool = false
    private(set) var userId: String   = ""
    private(set) var userRole: String = ""

    private init() {
        if let token  = KeychainManager.shared.loadToken(),
           let id     = KeychainManager.shared.loadUserId(),
           !token.isEmpty {
            userId    = id
            userRole  = jwtClaim("role", from: token) ?? ""
            isLoggedIn = true
        }
    }

    func save(token: String, userId: String) {
        KeychainManager.shared.saveToken(token)
        KeychainManager.shared.saveUserId(userId)
        self.userId   = userId
        self.userRole = jwtClaim("role", from: token) ?? ""
        isLoggedIn    = true
    }

    func logout() {
        KeychainManager.shared.clearAll()
        userId    = ""
        userRole  = ""
        isLoggedIn = false
    }

    // MARK: - JWT payload decoder (no verification — server validates)

    private func jwtClaim(_ key: String, from token: String) -> String? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }
        var b64 = String(parts[1])
        let rem = b64.count % 4
        if rem != 0 { b64 += String(repeating: "=", count: 4 - rem) }
        guard let data = Data(base64Encoded: b64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return json[key] as? String
    }

    func extractUserId(from token: String) -> String? {
        jwtClaim("sub", from: token)
    }
}
