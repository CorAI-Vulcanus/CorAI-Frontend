import Foundation

// Matches backend SensorECG schema
struct SensorECGPayload: Encodable {
    let v_mV: Int
    let t_us: Int
    let timestamp: String      // ISO 8601
}

// Matches backend SensorData schema
struct SensorDataPayload: Encodable {
    let fs: Int                // sampling frequency Hz
    let n_samples: Int
    let unit: String           // "mV"
    let freq_signal_Hz: Int
    let ecg: [SensorECGPayload]
}

extension SensorDataPayload {
    // Builds payload from normalized [Double] (0…1) samples.
    static func from(
        normalizedSamples: [Double],
        fs: Int = 500,
        sessionStart: Date
    ) -> SensorDataPayload {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let usPerSample = 1_000_000 / fs
        let ecg = normalizedSamples.enumerated().map { idx, value -> SensorECGPayload in
            let t_us = idx * usPerSample
            let sampleDate = sessionStart.addingTimeInterval(Double(t_us) / 1_000_000.0)
            return SensorECGPayload(
                v_mV: Int(value * 1000),
                t_us: t_us,
                timestamp: formatter.string(from: sampleDate)
            )
        }

        return SensorDataPayload(
            fs: fs,
            n_samples: normalizedSamples.count,
            unit: "mV",
            freq_signal_Hz: 50,
            ecg: ecg
        )
    }
}
