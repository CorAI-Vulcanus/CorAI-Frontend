import Foundation
import Combine

final class ECGWebSocketClient: NSObject, ObservableObject, URLSessionWebSocketDelegate {

    // MARK: - State

    @Published private(set) var samples: [Double] = []
    @Published private(set) var isConnected = false

    // MARK: - Private

    private var task: URLSessionWebSocketTask?
    private lazy var urlSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: nil
    )

    // MARK: - Public API

    func connect(userId: String) {
        guard let url = URL(string: "\(AppConfig.wsBaseURL)/ws/\(userId)") else { return }
        task = urlSession.webSocketTask(with: url)
        task?.resume()
        receive()
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        isConnected = false
    }

    func sendSample(vMV: Int, tUs: Int) {
        let msg: [String: Any] = ["type": "ecg_sample", "v_mV": vMV, "t_us": tUs]
        guard let data = try? JSONSerialization.data(withJSONObject: msg),
              let str  = String(data: data, encoding: .utf8)
        else { return }
        task?.send(.string(str)) { _ in }
    }

    // MARK: - Private

    private func receive() {
        task?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handle(message)
                self?.receive()
            case .failure:
                DispatchQueue.main.async { self?.isConnected = false }
            }
        }
    }

    private func handle(_ message: URLSessionWebSocketTask.Message) {
        guard case .string(let text) = message,
              let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              json["type"] as? String == "ecg_sample",
              let vMV = json["v_mV"] as? Int
        else { return }

        let normalized = Double(vMV) / 1000.0
        DispatchQueue.main.async {
            self.samples.append(normalized)
            if self.samples.count > 240 {    // ~2 s buffer a 120 Hz
                self.samples.removeFirst()
            }
        }
    }

    // MARK: - URLSessionWebSocketDelegate

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        DispatchQueue.main.async { self.isConnected = true }
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        DispatchQueue.main.async { self.isConnected = false }
    }
}
