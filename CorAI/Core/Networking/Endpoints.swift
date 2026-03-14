import Foundation

// MARK: - API Endpoints

enum Endpoint {
    case deviceStatus
    case ecgLive
    case metrics
    case reportGenerate

    // MARK: - Base URL (configure per environment)

    static var baseURL: String {
        // TODO: Replace with real server URL
        "https://api.corai.health/v1"
    }

    // MARK: - Path

    var path: String {
        switch self {
        case .deviceStatus:    return "/device/status"
        case .ecgLive:         return "/ecg/live"
        case .metrics:         return "/metrics"
        case .reportGenerate:  return "/report/generate"
        }
    }

    // MARK: - HTTP Method

    var method: String {
        switch self {
        case .deviceStatus, .ecgLive, .metrics:
            return "GET"
        case .reportGenerate:
            return "POST"
        }
    }

    // MARK: - Full URL

    var url: URL? {
        URL(string: Self.baseURL + path)
    }
}
