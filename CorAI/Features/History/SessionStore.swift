import Foundation

// MARK: - Session Store

/// Shared in-memory store that holds recorded ECG sessions.
/// Both the RecordingView and HistoryView observe this to stay in sync.
@Observable
final class SessionStore {

    /// All recorded sessions, newest first.
    var sessions: [ECGSession] = []

    /// Add a newly recorded session at the top.
    func add(_ session: ECGSession) {
        sessions.insert(session, at: 0)
    }
}
