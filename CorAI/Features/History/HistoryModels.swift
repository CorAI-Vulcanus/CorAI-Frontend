import Foundation

// MARK: - ECG Second Segment

/// One second of ECG recording data (~1-2 PQRST complexes at 72 BPM).
struct ECGSecondSegment: Identifiable, Equatable {
    let id: Int          // second index (0-based)
    let samples: [Double] // normalized ECG samples for this second
}

// MARK: - ECG Session

struct ECGSession: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let durationSeconds: Int
    let deviceId: String
    let filterOn: Bool
    let status: ECGSessionStatus
    let ecgSamples: [Double]             // preview data (small, for card thumbnail)
    let fullEcgData: [ECGSecondSegment]  // full recording, per second
    let isArchived: Bool

    /// Duration formatted as minutes for display.
    var durationMinutes: Int { durationSeconds / 60 }

    /// Duration formatted as "Xm Ys".
    var durationFormatted: String {
        let m = durationSeconds / 60
        let s = durationSeconds % 60
        if m > 0 {
            return "\(m) min \(s) s"
        }
        return "\(s) s"
    }

    init(
        id: UUID = UUID(),
        date: Date,
        durationSeconds: Int,
        deviceId: String,
        filterOn: Bool = true,
        status: ECGSessionStatus = .normal,
        ecgSamples: [Double] = [],
        fullEcgData: [ECGSecondSegment] = [],
        isArchived: Bool = false
    ) {
        self.id = id
        self.date = date
        self.durationSeconds = durationSeconds
        self.deviceId = deviceId
        self.filterOn = filterOn
        self.status = status
        self.ecgSamples = ecgSamples
        self.fullEcgData = fullEcgData
        self.isArchived = isArchived
    }
}

// MARK: - ECG Session Status

enum ECGSessionStatus: String, CaseIterable {
    case normal = "Normal"
    case review = "Review"
}

// MARK: - History Date Group

struct HistoryDateGroup: Identifiable {
    let id = UUID()
    let title: String          // e.g. "Hoy", "Esta semana"
    let sessions: [ECGSession]
}

// MARK: - History Filter

enum HistoryFilter: String, CaseIterable {
    case today      = "Hoy"
    case sevenDays  = "7 días"
    case thirtyDays = "30 días"
    case custom     = "Personalizado"
}

// MARK: - History Tab

enum HistoryTab: String, CaseIterable {
    case ecg     = "ECG"
    case metrics = "Métricas"
}
