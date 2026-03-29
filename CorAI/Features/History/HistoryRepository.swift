import Foundation

// MARK: - History Repository Protocol

protocol HistoryRepositoryProtocol: Sendable {
    func fetchSessions(filter: HistoryFilter) async throws -> [HistoryDateGroup]
}

// MARK: - Mock History Repository

final class MockHistoryRepository: HistoryRepositoryProtocol {

    /// Generate second-by-second full ECG data for a session.
    private func generateFullEcg(seconds: Int) -> [ECGSecondSegment] {
        (0..<seconds).map { sec in
            ECGSecondSegment(
                id: sec,
                samples: ECGDataGenerator.generateStream(complexes: 2, samplesPerComplex: 60)
            )
        }
    }

    func fetchSessions(filter: HistoryFilter) async throws -> [HistoryDateGroup] {
        // Simulate network latency
        try await Task.sleep(for: .milliseconds(300))

        let calendar = Calendar.current
        let now = Date()

        // --- "Hoy" sessions ---

        let session1Duration = 18 * 60 // 18 min in seconds
        let session1 = ECGSession(
            date: calendar.date(bySettingHour: 9, minute: 14, second: 0, of: now) ?? now,
            durationSeconds: session1Duration,
            deviceId: "Camisa #829",
            filterOn: true,
            status: .normal,
            ecgSamples: ECGDataGenerator.generateStream(complexes: 3, samplesPerComplex: 50),
            fullEcgData: generateFullEcg(seconds: session1Duration)
        )

        let session2Duration = 45 * 60 // 45 min in seconds
        let session2 = ECGSession(
            date: calendar.date(bySettingHour: 14, minute: 30, second: 0, of: now) ?? now,
            durationSeconds: session2Duration,
            deviceId: "Camisa #829",
            filterOn: true,
            status: .review,
            ecgSamples: ECGDataGenerator.generateStream(complexes: 3, samplesPerComplex: 50),
            fullEcgData: generateFullEcg(seconds: session2Duration)
        )

        let todayGroup = HistoryDateGroup(
            title: "Hoy",
            sessions: [session1, session2]
        )

        // --- "Esta semana" session (archived) ---

        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        let weekDate = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: threeDaysAgo) ?? threeDaysAgo

        let session3 = ECGSession(
            date: weekDate,
            durationSeconds: 12 * 60,
            deviceId: "Camisa #829",
            filterOn: true,
            status: .normal,
            ecgSamples: [],
            isArchived: true
        )

        let weekGroup = HistoryDateGroup(
            title: "Esta semana",
            sessions: [session3]
        )

        return [todayGroup, weekGroup]
    }
}
