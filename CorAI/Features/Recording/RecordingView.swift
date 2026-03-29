import SwiftUI

// MARK: - Recording View

/// Full-screen recording sheet showing live ECG, timer, BPM, and a stop button.
struct RecordingView: View {

    @State var viewModel: RecordingViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar

            Spacer()

            // Live stats
            statsSection

            // Live ECG waveform
            ecgSection

            Spacer()

            // Stop button
            stopButton

            Spacer().frame(height: AppSpacing.xl)
        }
        .background(Color.corBackground.ignoresSafeArea())
        .onAppear {
            viewModel.startRecording()
        }
    }
}

// MARK: - Subviews

private extension RecordingView {

    // -- Top Bar --

    var topBar: some View {
        HStack {
            Button {
                viewModel.stopRecording()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.corSearchBarBg)
                    .clipShape(Circle())
            }

            Spacer()

            // Recording indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .opacity(viewModel.isRecording ? 1.0 : 0.3)

                Text("REC")
                    .font(AppTypography.captionBold)
                    .foregroundStyle(.red)
            }

            Spacer()

            // Timer
            Text(viewModel.elapsedFormatted)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.corPrimaryText)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.md)
    }

    // -- Stats --

    var statsSection: some View {
        HStack(spacing: AppSpacing.xl) {
            // BPM
            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(viewModel.bpm)")
                        .font(AppTypography.bpmValue)
                        .foregroundStyle(Color.corPrimaryText)
                    Text("BPM")
                        .font(AppTypography.bpmUnit)
                        .foregroundStyle(.secondary)
                }
                Text("Frecuencia cardíaca")
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)
            }

            // Elapsed
            VStack(spacing: 2) {
                Text(viewModel.elapsedFormatted)
                    .font(AppTypography.metricValue)
                    .foregroundStyle(Color.corPrimaryText)
                Text("Tiempo")
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, AppSpacing.md)
    }

    // -- ECG Waveform --

    var ecgSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text("LIVE LEAD II")
                    .font(AppTypography.captionBold)
                    .foregroundStyle(.secondary)

                Spacer()

                Label("Grabando", systemImage: "circle.fill")
                    .font(AppTypography.captionBold)
                    .foregroundStyle(.red)
            }
            .padding(.horizontal, AppSpacing.md)

            RoundedCard {
                ECGChartView(samples: viewModel.liveSamples)
                    .frame(height: 160)
            }
            .padding(.horizontal, AppSpacing.md)

            // Metadata
            HStack {
                Text("25mm/s")
                Spacer()
                Text("10mm/mV")
                Spacer()
                Text("Filtro: ON")
            }
            .font(AppTypography.caption)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, AppSpacing.md)
        }
    }

    // -- Stop Button --

    var stopButton: some View {
        Button {
            viewModel.stopRecording()
            dismiss()
        } label: {
            VStack(spacing: AppSpacing.sm) {
                // Stop icon
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.white)
                    .frame(width: 28, height: 28)
                    .padding(20)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.red, .red.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .shadow(color: .red.opacity(0.4), radius: 10, x: 0, y: 4)

                Text("Detener grabación")
                    .font(AppTypography.captionBold)
                    .foregroundStyle(Color.corPrimaryText)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    RecordingView(viewModel: RecordingViewModel())
}
