import SwiftUI

// MARK: - CorAI Typography

enum AppTypography {
    static let largeTitle  = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title       = Font.system(size: 22, weight: .bold, design: .rounded)
    static let headline    = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body        = Font.system(size: 15, weight: .regular, design: .default)
    static let callout     = Font.system(size: 14, weight: .medium, design: .default)
    static let caption     = Font.system(size: 12, weight: .regular, design: .default)
    static let captionBold = Font.system(size: 12, weight: .semibold, design: .default)

    // Metrics
    static let metricValue = Font.system(size: 32, weight: .bold, design: .rounded)
    static let metricUnit  = Font.system(size: 13, weight: .medium, design: .default)
    static let metricLabel = Font.system(size: 13, weight: .regular, design: .default)

    // BPM
    static let bpmValue    = Font.system(size: 48, weight: .bold, design: .rounded)
    static let bpmUnit     = Font.system(size: 18, weight: .medium, design: .rounded)
}
