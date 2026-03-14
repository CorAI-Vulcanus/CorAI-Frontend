import SwiftUI

// MARK: - App Entry Point

@main
struct CorAIApp: App {

    // MARK: Dependencies

    private let repository: HomeRepositoryProtocol = MockHomeRepository()

    var body: some Scene {
        WindowGroup {
            MainTabView(repository: repository)
                .preferredColorScheme(.light)
        }
    }
}
