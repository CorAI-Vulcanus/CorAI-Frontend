import Foundation
import Security

final class KeychainManager: @unchecked Sendable {
    static let shared = KeychainManager()

    private let tokenKey  = "corai.jwt.token"
    private let userIdKey = "corai.user.id"

    func saveToken(_ token: String)  { save(key: tokenKey,  value: token) }
    func loadToken()   -> String?    { load(key: tokenKey) }
    func saveUserId(_ id: String)    { save(key: userIdKey, value: id) }
    func loadUserId()  -> String?    { load(key: userIdKey) }

    func clearAll() {
        delete(key: tokenKey)
        delete(key: userIdKey)
    }

    // MARK: - Private

    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        delete(key: key)
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData:   data,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func load(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
