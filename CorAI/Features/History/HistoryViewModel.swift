import Foundation

// MARK: - History ViewModel

@Observable
final class HistoryViewModel {

    // MARK: Published state

    var dateGroups: [HistoryDateGroup] = []
    var selectedFilter: HistoryFilter = .today
    var selectedTab: HistoryTab = .ecg
    var searchText: String = ""
    var isLoading = false
    var errorMessage: String?

    // MARK: Dependencies

    private let repository: HistoryRepositoryProtocol
    let sessionStore: SessionStore

    // MARK: Init

    init(
        repository: HistoryRepositoryProtocol = HistoryRepository(),
        sessionStore: SessionStore = SessionStore()
    ) {
        self.repository = repository
        self.sessionStore = sessionStore
    }

    // MARK: - Lifecycle

    func onAppear() {
        Task { await loadSessions() }
    }

    // MARK: - Filter Change

    func filterChanged(to filter: HistoryFilter) {
        selectedFilter = filter
        Task { await loadSessions() }
    }

    // MARK: - Data Loading

    @MainActor
    func loadSessions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            var groups = try await repository.fetchSessions(filter: selectedFilter)
            // Merge locally recorded sessions not yet synced

            if !sessionStore.sessions.isEmpty {
                let recordedGroup = HistoryDateGroup(
                    title: "Grabaciones recientes",
                    sessions: sessionStore.sessions
                )
                groups.insert(recordedGroup, at: 0)
            }

            dateGroups = groups
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Formatted date helpers

    static let sessionDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.dateFormat = "EEE dd MMM"
        return f
    }()

    static let sessionTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.dateFormat = "HH:mm"
        return f
    }()

    static let sessionTimeWithSecondsFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    func formattedDate(_ date: Date) -> String {
        Self.sessionDateFormatter.string(from: date).localizedCapitalized
    }

    func formattedTime(_ date: Date) -> String {
        Self.sessionTimeFormatter.string(from: date)
    }
}
