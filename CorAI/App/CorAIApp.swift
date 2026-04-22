import SwiftUI

@main
struct CorAIApp: App {
    @State private var session = SessionManager.shared

    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                MainTabView(repository: MockHomeRepository())
                    .preferredColorScheme(.light)
            } else {
                LoginView()
                    .preferredColorScheme(.light)
            }
        }
    }
}
