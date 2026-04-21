import Foundation
import Combine

@Observable
final class HomeViewModel {

    // MARK: - State

    var ecgSamples: [Double] = ECGDataGenerator.generateStream()
    var metrics: HeartMetrics = HeartMetrics(
        bpm: 72, hrv: 42, stressLevel: .low,
        temperature: 36.6, respirationRate: 14
    )
    var deviceStatus: DeviceStatus = DeviceStatus(
        deviceId: "Shirt #1",
        connectionState: .connected,
        batteryLevel: 85
    )
    var isLoading    = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let repository: HomeRepositoryProtocol
    private let wsClient   = ECGWebSocketClient()
    private let session    = SessionManager.shared
    private var ecgTimer: AnyCancellable?

    // When the WebSocket is not connected, fall back to simulated ECG
    private var useWebSocket: Bool { wsClient.isConnected }

    // MARK: - Init

    init(repository: HomeRepositoryProtocol = MockHomeRepository()) {
        self.repository = repository
    }

    // MARK: - Lifecycle

    func onAppear() {
        Task { await loadInitialData() }
        connectWebSocket()
        startLocalECGTimer()
    }

    func onDisappear() {
        ecgTimer?.cancel()
        ecgTimer = nil
        wsClient.disconnect()
    }

    // MARK: - WebSocket

    private func connectWebSocket() {
        let userId = session.userId
        guard !userId.isEmpty else { return }
        wsClient.connect(userId: userId)
    }

    // MARK: - ECG local timer (fallback when WS not connected)

    private func startLocalECGTimer() {
        ecgTimer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.useWebSocket, !self.wsClient.samples.isEmpty {
                    // Use live samples from WebSocket
                    self.ecgSamples = self.wsClient.samples
                } else {
                    // Simulate locally while no WS data
                    self.advanceSimulatedECG()
                }
            }
    }

    // MARK: - Data Loading

    @MainActor
    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            deviceStatus = try await repository.fetchDeviceStatus()
            metrics      = try await repository.fetchMetrics()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private

    private func advanceSimulatedECG() {
        let shiftSize = 4
        var buffer = ecgSamples
        buffer.removeFirst(min(shiftSize, buffer.count))
        let fragment = ECGDataGenerator.generateComplex(sampleCount: 60)
        let slice    = Array(fragment.prefix(shiftSize)).map { $0 + Double.random(in: -0.005...0.005) }
        buffer.append(contentsOf: slice)
        ecgSamples = buffer
    }
}
