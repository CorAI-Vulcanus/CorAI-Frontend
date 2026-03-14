import Foundation
import Combine

// MARK: - Home ViewModel

@Observable
final class HomeViewModel {

    // MARK: Published state

    var ecgSamples: [Double] = ECGDataGenerator.generateStream()
    var metrics: HeartMetrics = HeartMetrics(
        bpm: 72, hrv: 42, stressLevel: .low,
        temperature: 36.6, respirationRate: 14
    )
    var deviceStatus: DeviceStatus = DeviceStatus(
        deviceId: "Shirt #1",
        connectionState: .connected, batteryLevel: 85
    )
    var isLoading = false
    var errorMessage: String?

    // MARK: Private

    private let repository: HomeRepositoryProtocol
    private var ecgTimer: AnyCancellable?

    // MARK: Init

    init(repository: HomeRepositoryProtocol = MockHomeRepository()) {
        self.repository = repository
    }

    // MARK: - Lifecycle

    func onAppear() {
        startECGStream()
        Task { await loadInitialData() }
    }

    func onDisappear() {
        stopECGStream()
    }

    // MARK: - ECG Stream

    func startECGStream() {
        ecgTimer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.advanceECG()
            }
    }

    func stopECGStream() {
        ecgTimer?.cancel()
        ecgTimer = nil
    }

    // MARK: - Data Loading

    @MainActor
    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let status = try await repository.fetchDeviceStatus()
            deviceStatus = status

            let newMetrics = try await repository.fetchMetrics()
            metrics = newMetrics
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private helpers

    private func advanceECG() {
        // Shift the buffer left by a small chunk and append new data
        let shiftSize = 4
        var buffer = ecgSamples
        buffer.removeFirst(min(shiftSize, buffer.count))

        // Append new samples from a fresh complex fragment
        let fragment = ECGDataGenerator.generateComplex(sampleCount: 60)
        let slice = Array(fragment.prefix(shiftSize)).map { $0 + Double.random(in: -0.005...0.005) }
        buffer.append(contentsOf: slice)

        ecgSamples = buffer
    }
}
