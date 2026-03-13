import SwiftUI

// MARK: - Home View

struct HomeView: View {

    @State var viewModel: HomeViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                headerSection
                ecgCard
                metricsGrid
                analysisSection
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(Color.corBackground.ignoresSafeArea())
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }
}

// MARK: - Header

private extension HomeView {
    var headerSection: some View {
        HStack(spacing: AppSpacing.sm) {
            // Logo icon
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.corTeal)

            VStack(alignment: .leading, spacing: 2) {
                Text("CorAI")
                    .font(AppTypography.title)
                    .foregroundStyle(Color.corPrimaryText)

                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)

                    Text("\(viewModel.deviceStatus.connectionState.rawValue) • \(viewModel.deviceStatus.deviceId)")
                        .font(AppTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.top, AppSpacing.sm)
    }

    var statusColor: Color {
        switch viewModel.deviceStatus.connectionState {
        case .connected:    return .corStatusGreen
        case .connecting:   return .orange
        case .disconnected: return .red
        }
    }
}

// MARK: - Live ECG Card

private extension HomeView {
    var ecgCard: some View {
        RoundedCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Title row
                HStack {
                    Text("LIVE LEAD II")
                        .font(AppTypography.captionBold)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Status badge
                    Label("Normal", systemImage: "heart.fill")
                        .font(AppTypography.captionBold)
                        .foregroundStyle(Color.corTeal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.corTeal.opacity(0.12))
                        .clipShape(Capsule())
                }

                // BPM
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(viewModel.metrics.bpm)")
                        .font(AppTypography.bpmValue)
                        .foregroundStyle(Color.corPrimaryText)
                    Text("BPM")
                        .font(AppTypography.bpmUnit)
                        .foregroundStyle(.secondary)
                }

                // ECG Chart
                ECGChartView(samples: viewModel.ecgSamples)
                    .frame(height: 120)

                // Metadata row
                HStack {
                    Text("25mm/s")
                    Spacer()
                    Text("10mm/mV")
                    Spacer()
                    Text("Filter: On")
                }
                .font(AppTypography.caption)
                .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Metrics Grid

private extension HomeView {
    var metricsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: AppSpacing.gridSpacing),
            GridItem(.flexible(), spacing: AppSpacing.gridSpacing)
        ]

        return LazyVGrid(columns: columns, spacing: AppSpacing.gridSpacing) {
            MetricCard(
                icon: "waveform.path.ecg",
                iconColor: .purple,
                iconBackground: Color.corHRVIconBg,
                value: "\(viewModel.metrics.hrv)",
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
                value: viewModel.metrics.stressLevel.rawValue,
                unit: "",
                label: "Stress Level",
                trend: "↓ 2%",
                trendColor: .red
            )
            
            MetricCard(
                icon: "lungs.fill",
                iconColor: .teal,
                iconBackground: Color.corRespIconBg,
                value: "\(viewModel.metrics.respirationRate)",
                unit: "rpm",
                label: "Respiration Rate (RPM)"
            )
/*
            MetricCard(
                icon: "thermometer.medium",
                iconColor: .blue,
                iconBackground: Color.corTempIconBg,
                value: String(format: "%.1f", viewModel.metrics.temperature),
                unit: "°C",
                label: "Skin Temp"
            )
 
            MetricCard(
                icon: "lungs.fill",
                iconColor: .teal,
                iconBackground: Color.corRespIconBg,
                value: "\(viewModel.metrics.respirationRate)",
                unit: "rpm",
                label: "Resp. Rate"
            )
 */
        }
    }
}

// MARK: - Analysis Section

private extension HomeView {
    var analysisSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("ANALYSIS")
                .font(AppTypography.captionBold)
                .foregroundStyle(.secondary)

            RoundedCard {
                HStack(spacing: AppSpacing.md) {
                    // Report icon
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.corTeal)
                        .frame(width: 44, height: 44)
                        .background(Color.corTeal.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Generate Full Report")
                            .font(AppTypography.headline)
                            .foregroundStyle(Color.corPrimaryText)

                        Text("Export PDF for your cardiologist")
                            .font(AppTypography.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView(viewModel: HomeViewModel())
}
