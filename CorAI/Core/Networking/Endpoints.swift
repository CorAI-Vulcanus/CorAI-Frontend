import Foundation

enum Endpoint {
    // Auth
    case signIn
    case login
    case logout
    case getUser(userId: String)
    case updateUser(userId: String)

    // Patient
    case getPatient(userId: String)
    case updatePatient(userId: String)
    case ingestECG(userId: String)
    case getECGSessions(userId: String)
    case getPatients

    // Admin
    case adminUsers
    case adminCreateUser
    case adminDeactivateUser(userId: String)
    case adminDeleteUser(userId: String)

    // MARK: - Path

    var path: String {
        switch self {
        case .signIn:                          return "/user/sign-in"
        case .login:                           return "/user/login"
        case .logout:                          return "/user/logout"
        case .getUser(let id):                 return "/user/\(id)"
        case .updateUser(let id):              return "/user/\(id)"
        case .getPatient(let id):              return "/patient/\(id)"
        case .updatePatient(let id):           return "/patient/\(id)"
        case .ingestECG(let id):               return "/patient/ingest/\(id)"
        case .getECGSessions(let id):          return "/patient/\(id)/sessions"
        case .getPatients:                     return "/patients"
        case .adminUsers:                      return "/admin/users"
        case .adminCreateUser:                 return "/admin/users"
        case .adminDeactivateUser(let id):     return "/admin/user/\(id)"
        case .adminDeleteUser(let id):         return "/admin/user/\(id)"
        }
    }

    // MARK: - HTTP Method

    var method: String {
        switch self {
        case .login, .signIn, .ingestECG, .adminCreateUser:
            return "POST"
        case .updateUser, .updatePatient, .adminDeactivateUser:
            return "PUT"
        case .logout, .getUser, .getPatient, .getECGSessions,
             .getPatients, .adminUsers, .adminDeleteUser:
            return "GET"
        }
    }

    // MARK: - Full URL

    var url: URL? {
        URL(string: AppConfig.baseURL + path)
    }
}
