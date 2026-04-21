import Foundation

enum AppConfig {
    // Simulador: http://localhost:8000
    // Dispositivo físico: http://<IP-local-del-Mac>:8000
    static let baseURL = "http://192.168.100.34:8000"

    // WebSocket (ws:// en desarrollo, wss:// en producción)
    static let wsBaseURL = "ws://192.168.100.34:8000"
}
