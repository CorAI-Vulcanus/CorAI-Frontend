import Foundation

// MARK: - Home Repository Protocol

protocol HomeRepositoryProtocol: Sendable {
    func fetchDeviceStatus() async throws -> DeviceStatus
    func fetchMetrics() async throws -> HeartMetrics
    func streamECG() async throws -> [Double]
}

// MARK: - Mock Home Repository

final class MockHomeRepository: HomeRepositoryProtocol {

    func fetchDeviceStatus() async throws -> DeviceStatus {
        // Simulate network latency
        try await Task.sleep(for: .milliseconds(200))

        return DeviceStatus(
            deviceId: "Shirt #1",
            connectionState: .connected,
            batteryLevel: 87
        )
    }

    func fetchMetrics() async throws -> HeartMetrics {
        try await Task.sleep(for: .milliseconds(150))

        return HeartMetrics(
            bpm: 72,
            hrv: 42,
            stressLevel: .low,
            temperature: 36.6,
            respirationRate: 14
        )
    }

    func streamECG() async throws -> [Double] {
        // Returns one fresh batch of simulated ECG data
        return ECGDataGenerator.generateStream(complexes: 4, samplesPerComplex: 60)
    }
}

