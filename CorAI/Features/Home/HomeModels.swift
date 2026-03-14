import Foundation

// MARK: - Heart Metrics

struct HeartMetrics: Identifiable, Equatable {
    let id = UUID()
    var bpm: Int
    var hrv: Int                    // SDNN in ms
    var stressLevel: StressLevel
    var temperature: Double         // °C
    var respirationRate: Int        // rpm
}

enum StressLevel: String, CaseIterable {
    case low    = "Low"
    case medium = "Medium"
    case high   = "High"
}

// MARK: - ECG Sample

struct ECGSample: Identifiable {
    let id = UUID()
    let timestamp: Date
    let value: Double               // normalized 0…1
}

// MARK: - Device Status

struct DeviceStatus: Equatable {
    let deviceId: String
    var connectionState: ConnectionState
    var batteryLevel: Int // 0-100
}

enum ConnectionState: String {
    case connected    = "Connected"
    case disconnected = "Disconnected"
    case connecting   = "Connecting"
}
