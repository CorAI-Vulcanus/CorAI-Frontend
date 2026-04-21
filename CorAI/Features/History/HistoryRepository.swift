import Foundation

// MARK: - Protocol

protocol HistoryRepositoryProtocol: Sendable {
    func fetchSessions(filter: HistoryFilter) async throws -> [HistoryDateGroup]
}

// MARK: - Live Repository

final class HistoryRepository: HistoryRepositoryProtocol {
    private let client: APIClientProtocol
    private let session: SessionManager

    init(
        client: APIClientProtocol = APIClient(),
        session: SessionManager = .shared
    ) {
        self.client  = client
        self.session = session
    }

    func fetchSessions(filter: HistoryFilter) async throws -> [HistoryDateGroup] {
        let raw: [SensorSessionResponse] = try await client.request(
            .getECGSessions(userId: session.userId), body: nil
        )
        let sessions = raw.map { $0.toECGSession() }
        return group(sessions: sessions, filter: filter)
    }

    // MARK: - Grouping

    private func group(sessions: [ECGSession], filter: HistoryFilter) -> [HistoryDateGroup] {
        let calendar = Calendar.current
        let filtered = sessions.filter { apply(filter: filter, to: $0.date) }
        let byDay    = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.date) }

        return byDay.keys.sorted(by: >).map { day in
            HistoryDateGroup(
                title: label(for: day, calendar: calendar),
                sessions: byDay[day]!.sorted { $0.date > $1.date }
            )
        }
    }

    private func apply(filter: HistoryFilter, to date: Date) -> Bool {
        let now = Date()
        switch filter {
        case .today:      return Calendar.current.isDateInToday(date)
        case .sevenDays:  return date >= now.addingTimeInterval(-7  * 86_400)
        case .thirtyDays: return date >= now.addingTimeInterval(-30 * 86_400)
        case .custom:     return true
        }
    }

    private func label(for day: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(day)     { return "Hoy" }
        if calendar.isDateInYesterday(day) { return "Ayer" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale    = Locale(identifier: "es_MX")
        return f.string(from: day)
    }
}

// MARK: - Mock (para previews y desarrollo sin backend)

final class MockHistoryRepository: HistoryRepositoryProtocol {

    private func generateFullEcg(seconds: Int) -> [ECGSecondSegment] {
        (0..<seconds).map { sec in
            ECGSecondSegment(
                id: sec,
                samples: ECGDataGenerator.generateStream(complexes: 2, samplesPerComplex: 60)
            )
        }
    }

    func fetchSessions(filter: HistoryFilter) async throws -> [HistoryDateGroup] {
        try await Task.sleep(for: .milliseconds(300))

        let calendar = Calendar.current
        let now      = Date()

        let s1 = ECGSession(
            date: calendar.date(bySettingHour: 9, minute: 14, second: 0, of: now) ?? now,
            durationSeconds: 18 * 60,
            deviceId: "Camisa #829",
            filterOn: true,
            status: .normal,
            ecgSamples: ECGDataGenerator.generateStream(complexes: 3, samplesPerComplex: 50),
            fullEcgData: generateFullEcg(seconds: 18 * 60)
        )

        let s2 = ECGSession(
            date: calendar.date(bySettingHour: 14, minute: 30, second: 0, of: now) ?? now,
            durationSeconds: 45 * 60,
            deviceId: "Camisa #829",
            filterOn: true,
            status: .review,
            ecgSamples: ECGDataGenerator.generateStream(complexes: 3, samplesPerComplex: 50),
            fullEcgData: generateFullEcg(seconds: 45 * 60)
        )

        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        let s3 = ECGSession(
            date: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: threeDaysAgo) ?? threeDaysAgo,
            durationSeconds: 12 * 60,
            deviceId: "Camisa #829",
            filterOn: true,
            status: .normal,
            ecgSamples: [],
            isArchived: true
        )

        return [
            HistoryDateGroup(title: "Hoy",         sessions: [s1, s2]),
            HistoryDateGroup(title: "Esta semana",  sessions: [s3]),
        ]
    }
}
