import SwiftUI

// MARK: - Metric Card

/// Reusable card for displaying a health metric with icon, value, unit, and label.
struct MetricCard: View {

    let icon: String
    let iconColor: Color
    let iconBackground: Color
    let value: String
    let unit: String
    let label: String
    var subtitle: String? = nil
    var statusLabel: String? = nil
    var statusColor: Color = .green
    var trend: String? = nil
    var trendColor: Color = .red

    var body: some View {
        RoundedCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Top row: icon + status/trend
                HStack(alignment: .top) {
                    // Icon badge
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(iconColor)
                        .frame(width: 36, height: 36)
                        .background(iconBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Spacer()

                    // Status or trend (top-right)
                    if let statusLabel = statusLabel {
                        Text(statusLabel)
                            .font(AppTypography.captionBold)
                            .foregroundStyle(statusColor)
                    } else if let trend = trend {
                        Text(trend)
                            .font(AppTypography.caption)
                            .foregroundStyle(trendColor)
                    }
                }

                Spacer(minLength: 0)

                // Value + Unit on same line
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(AppTypography.metricValue)
                        .foregroundStyle(Color.corPrimaryText)

                    if !unit.isEmpty {
                        Text(unit)
                            .font(AppTypography.metricUnit)
                            .foregroundStyle(.secondary)
                    }
                }

                // Subtitle (e.g. "Heart Recovery")
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppTypography.metricLabel)
                        .foregroundStyle(.secondary)
                }

                // Technical label
                Text(label)
                    .font(AppTypography.metricLabel)
                    .foregroundStyle(.tertiary)
            }
            .frame(minHeight: 130)
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: AppSpacing.gridSpacing) {
        MetricCard(
            icon: "waveform.path.ecg",
            iconColor: .purple,
            iconBackground: Color.corHRVIconBg,
            value: "42",
            unit: "ms",
            label: "HRV (SDNN)",
            subtitle: "Heart Recovery",
            statusLabel: "Normal",
            statusColor: .green
        )

        MetricCard(
            icon: "figure.mind.and.body",
            iconColor: .orange,
            iconBackground: Color.corStressIconBg,
            value: "Low",
            unit: "",
            label: "Stress Level",
            trend: "↓ 2%",
            trendColor: .red
        )
    }
    .padding()
    .background(Color.corBackground)
}
