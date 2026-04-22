import Foundation

// POST /user/login
struct LoginRequest: Encodable {
    let user_name: String
    let password: String
}

// POST /user/login → {"token": "..."}
struct LoginResponse: Decodable {
    let token: String
}

// POST /user/sign-in
struct SignInRequest: Encodable {
    let user_name: String
    let password: String
    let name: String
    let email: String
    let phone_number: String
    let role: String          // "Doctor" | "Patient" | "Admin"
}

// GET /user/{id}
struct UserProfile: Decodable {
    let id: String
    let username: String
    let name: String?
    let email: String
    let role: String
    let is_active: Bool
}
