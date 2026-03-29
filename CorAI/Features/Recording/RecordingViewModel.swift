import Foundation
import Combine

// MARK: - Recording ViewModel

/// Manages a live ECG recording session.
/// Accumulates 1 second of simulated ECG data every second,
/// stores it as `ECGSecondSegment` entries, and builds the session when stopped.
@Observable
final class RecordingViewModel {

    // MARK: - State

    var isRecording = false
    var elapsedSeconds: Int = 0
    var liveSamples: [Double] = ECGDataGenerator.generateStream(complexes: 4, samplesPerComplex: 60)
    var bpm: Int = 72

    // MARK: - Completion callback

    var onSessionSaved: ((ECGSession) -> Void)?

    // MARK: - Private

    private var recordedSegments: [ECGSecondSegment] = []
    private var timer: AnyCancellable?
    private var ecgTimer: AnyCancellable?
    private let deviceId: String

    // MARK: - Init

    init(deviceId: String = "Camisa #829") {
        self.deviceId = deviceId
    }

    // MARK: - Start Recording

    func startRecording() {
        isRecording = true
        elapsedSeconds = 0
        recordedSegments = []
        liveSamples = ECGDataGenerator.generateStream(complexes: 4, samplesPerComplex: 60)

        // 1-second tick: accumulate one second of ECG data
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }

        // Fast tick for live animation (~200ms)
        ecgTimer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.advanceLiveECG()
            }
    }

    // MARK: - Stop Recording

    func stopRecording() {
        isRecording = false
        timer?.cancel()
        timer = nil
        ecgTimer?.cancel()
        ecgTimer = nil

        // Build the session
        let session = ECGSession(
            date: Date().addingTimeInterval(-Double(elapsedSeconds)), // session start time
            durationSeconds: elapsedSeconds,
            deviceId: deviceId,
            filterOn: true,
            status: .normal,
            ecgSamples: ECGDataGenerator.generateStream(complexes: 3, samplesPerComplex: 50),
            fullEcgData: recordedSegments
        )

        onSessionSaved?(session)
    }

    // MARK: - Formatted elapsed time

    var elapsedFormatted: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Private

    private func tick() {
        // Generate ~1.2 PQRST complexes worth of samples for this second
        let segment = ECGSecondSegment(
            id: elapsedSeconds,
            samples: ECGDataGenerator.generateStream(complexes: 2, samplesPerComplex: 60)
        )
        recordedSegments.append(segment)
        elapsedSeconds += 1

        // Simulate slight BPM variation
        bpm = Int.random(in: 68...78)
    }

    private func advanceLiveECG() {
        let shiftSize = 4
        var buffer = liveSamples
        buffer.removeFirst(min(shiftSize, buffer.count))

        let fragment = ECGDataGenerator.generateComplex(sampleCount: 60)
        let slice = Array(fragment.prefix(shiftSize)).map { $0 + Double.random(in: -0.005...0.005) }
        buffer.append(contentsOf: slice)

        liveSamples = buffer
    }
}
