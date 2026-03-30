import SwiftUI

// MARK: - ECG History Card

/// Displays a single ECG session in a card matching the Historial mockup.
struct ECGHistoryCardView: View {

    let session: ECGSession
    let viewModel: HistoryViewModel

    var body: some View {
        RoundedCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Row 1: Date/time + status badge
                headerRow

                // Row 2: Duration
                Text("Duración: \(session.durationFormatted)")
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)

                // Row 3: ECG preview or archived placeholder
                ecgPreview

                // Row 4: Device info + share
                footerRow
            }
        }
    }
}

// MARK: - Subviews

private extension ECGHistoryCardView {

    // Header: Date + Status badge
    var headerRow: some View {
        HStack(alignment: .top) {
            HStack(spacing: AppSpacing.xs) {
                Text(viewModel.formattedDate(session.date))
                    .font(AppTypography.headline)
                    .foregroundStyle(Color.corPrimaryText)

                Text(viewModel.formattedTime(session.date))
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            statusBadge
        }
    }

    // Status badge (Normal = teal heart, Review = amber flag)
    var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: session.status == .normal ? "heart.fill" : "flag.fill")
                .font(.system(size: 10))

            Text(session.status.rawValue)
                .font(AppTypography.captionBold)
        }
        .foregroundStyle(session.status == .normal ? Color.corTeal : Color.corStatusReview)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            (session.status == .normal ? Color.corTeal : Color.corStatusReview)
                .opacity(0.12)
        )
        .clipShape(Capsule())
    }

    // ECG preview or archived placeholder
    @ViewBuilder
    var ecgPreview: some View {
        if session.isArchived {
            // Archived — show placeholder
            HStack {
                Spacer()
                VStack(spacing: AppSpacing.xs) {
                    Image(systemName: "eye")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    Text("Preview archived")
                        .font(AppTypography.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .frame(height: 80)
            .background(Color.corBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            // Live waveform preview
            ECGChartView(samples: session.ecgSamples)
                .frame(height: 80)
                .allowsHitTesting(false)
        }
    }

    // Footer: Device + Filter + Share
    var footerRow: some View {
        HStack(spacing: AppSpacing.md) {
            // Device
            Label(session.deviceId, systemImage: "tshirt.fill")
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)

            // Filter status
            Label("Filtro: \(session.filterOn ? "ON" : "OFF")", systemImage: "slider.horizontal.3")
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)

            Spacer()

            // Share button
            Button {
                // Future: share session
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.corTeal)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = HistoryViewModel()
    let session = ECGSession(
        date: Date(),
        durationSeconds: 18 * 60,
        deviceId: "Camisa #829",
        filterOn: true,
        status: .normal,
        ecgSamples: ECGDataGenerator.generateStream(complexes: 3, samplesPerComplex: 50)
    )

    ECGHistoryCardView(session: session, viewModel: vm)
        .padding()
        .background(Color.corBackground)
}
