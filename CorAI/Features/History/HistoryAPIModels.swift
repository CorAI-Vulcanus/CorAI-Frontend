import Foundation

// MARK: - Backend response shapes

struct SensorECGResponse: Decodable {
    let v_mV: Int
    let t_us: Int
    let timestamp: String?
}

struct SensorSessionResponse: Decodable {
    let id: String
    let fs: Int
    let n_samples: Int
    let unit: String
    let freq_signal_Hz: Int
    let created_at: String?
    let ecg: [SensorECGResponse]

    // MARK: - Convert to local ECGSession

    func toECGSession() -> ECGSession {
        let normalizedSamples = ecg.map { Double($0.v_mV) / 1000.0 }
        let sessionStart = created_at.flatMap { parseISO($0) } ?? Date()

        // Estimate duration from last t_us (microseconds → seconds)
        let durationSec = ecg.last.map { $0.t_us / 1_000_000 } ?? 0

        return ECGSession(
            id: UUID(uuidString: id) ?? UUID(),
            date: sessionStart,
            durationSeconds: durationSec,
            deviceId: "Servidor",
            filterOn: true,
            status: .normal,
            ecgSamples: Array(normalizedSamples.prefix(120)),
            fullEcgData: buildSegments(samples: normalizedSamples, fs: fs)
        )
    }

    private func parseISO(_ str: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: str) { return d }
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: str)
    }

    private func buildSegments(samples: [Double], fs: Int) -> [ECGSecondSegment] {
        guard fs > 0 else { return [] }
        return stride(from: 0, to: samples.count, by: fs).enumerated().map { idx, start in
            let end = min(start + fs, samples.count)
            return ECGSecondSegment(id: idx, samples: Array(samples[start..<end]))
        }
    }
}
