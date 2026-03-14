import SwiftUI

// MARK: - CorAI Brand Colors

extension Color {
    // Primary palette
    static let corPrimaryDarkBlue = Color(hex: "023059")
    static let corSecondaryBlue   = Color(hex: "023859")
    static let corTeal            = Color(hex: "34B1BF")
    static let corLightTeal       = Color(hex: "30BFBF")
    static let corBackgroundGray  = Color(hex: "F2F2F2")

    // Semantic aliases
    static let corBackground      = corBackgroundGray
    static let corCardBackground   = Color.white
    static let corPrimaryText      = corPrimaryDarkBlue
    static let corSecondaryText    = Color.gray
    static let corAccent           = corTeal
    static let corStatusGreen      = Color(hex: "34C759")

    // Metric icon backgrounds
    static let corHRVIconBg        = Color(hex: "EDE7F6")  // soft purple
    static let corStressIconBg     = Color(hex: "FFF3E0")  // soft orange
    static let corTempIconBg       = Color(hex: "E3F2FD")  // soft blue
    static let corRespIconBg       = Color(hex: "E0F7FA")  // soft teal
}

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: Double
        switch hex.count {
        case 6:
            (r, g, b, a) = (
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8)  & 0xFF) / 255,
                Double(int         & 0xFF) / 255,
                1
            )
        case 8:
            (r, g, b, a) = (
                Double((int >> 24) & 0xFF) / 255,
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8)  & 0xFF) / 255,
                Double(int         & 0xFF) / 255
            )
        default:
            (r, g, b, a) = (0, 0, 0, 1)
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
