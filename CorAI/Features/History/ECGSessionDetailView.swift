import SwiftUI

// MARK: - ECG Session Detail View

/// Full-screen ECG recording viewer with second-by-second navigation.
/// Supports landscape rotation for wide waveform display.
struct ECGSessionDetailView: View {

    let session: ECGSession

    @State private var selectedSecond: Int = 0
    @Environment(\.dismiss) private var dismiss

    private var totalSeconds: Int { session.durationSeconds }

    // Date formatters
    private var formattedDate: String {
        HistoryViewModel.sessionDateFormatter.string(from: session.date).localizedCapitalized
    }
    private var formattedTime: String {
        HistoryViewModel.sessionTimeFormatter.string(from: session.date)
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            if isLandscape {
                landscapeLayout(geo: geo)
            } else {
                portraitLayout(geo: geo)
            }
        }
        .background(Color.corBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sesión ECG")
                    .font(AppTypography.headline)
                    .foregroundStyle(Color.corPrimaryText)
            }
        }
    }
}

// MARK: - Portrait Layout

private extension ECGSessionDetailView {
    func portraitLayout(geo: GeometryProxy) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                sessionHeader
                statusBadge
                secondLabel
                ecgWaveformCard(height: 200)
                timelineScrubber
                metadataSection
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
    }
}

// MARK: - Landscape Layout

private extension ECGSessionDetailView {
    func landscapeLayout(geo: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Left sidebar
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                sessionHeaderCompact
                statusBadge
                Spacer()
                metadataSectionCompact
            }
            .frame(width: min(geo.size.width * 0.25, 180))
            .padding(AppSpacing.md)

            // Right: full-width ECG + scrubber
            VStack(spacing: AppSpacing.sm) {
                secondLabel
                ecgWaveformCard(height: geo.size.height * 0.50)
                timelineScrubber
            }
            .padding(.vertical, AppSpacing.sm)
            .padding(.trailing, AppSpacing.md)
        }
    }
}

// MARK: - Shared Components

private extension ECGSessionDetailView {

    // -- Session Header (Portrait) --

    var sessionHeader: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 24))
                .foregroundStyle(Color.corTeal)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(formattedDate)  \(formattedTime)")
                    .font(AppTypography.headline)
                    .foregroundStyle(Color.corPrimaryText)

                Text("Duración: \(session.durationFormatted)")
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, AppSpacing.sm)
    }

    // -- Session Header Compact (Landscape) --

    var sessionHeaderCompact: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(formattedDate)
                .font(AppTypography.headline)
                .foregroundStyle(Color.corPrimaryText)

            Text(formattedTime)
                .font(AppTypography.callout)
                .foregroundStyle(.secondary)

            Text(session.durationFormatted)
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
        }
    }

    // -- Status Badge --

    var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: session.status == .normal ? "heart.fill" : "flag.fill")
                .font(.system(size: 10))

            Text(session.status.rawValue)
                .font(AppTypography.captionBold)
        }
        .foregroundStyle(session.status == .normal ? Color.corTeal : Color.corStatusReview)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            (session.status == .normal ? Color.corTeal : Color.corStatusReview)
                .opacity(0.12)
        )
        .clipShape(Capsule())
    }

    // -- Second Label --

    var secondLabel: some View {
        HStack {
            Text("Segundo \(selectedSecond + 1) de \(totalSeconds)")
                .font(AppTypography.captionBold)
                .foregroundStyle(Color.corPrimaryText)

            Spacer()

            Text(secondTimeString)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    var secondTimeString: String {
        let m = selectedSecond / 60
        let s = selectedSecond % 60
        return String(format: "%02d:%02d", m, s)
    }

    // -- ECG Waveform Card --

    func ecgWaveformCard(height: CGFloat) -> some View {
        RoundedCard {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text("LEAD II")
                        .font(AppTypography.captionBold)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("25mm/s")
                        .font(AppTypography.caption)
                        .foregroundStyle(.tertiary)

                    Text("10mm/mV")
                        .font(AppTypography.caption)
                        .foregroundStyle(.tertiary)
                }

                if selectedSecond < session.fullEcgData.count {
                    ECGChartView(samples: session.fullEcgData[selectedSecond].samples)
                        .frame(height: height)
                        .id(selectedSecond)
                } else {
                    Text("Sin datos para este segundo")
                        .font(AppTypography.caption)
                        .foregroundStyle(.tertiary)
                        .frame(height: height)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // -- Timeline Scrubber --

    var timelineScrubber: some View {
        VStack(spacing: AppSpacing.xs) {
            // Slider
            Slider(
                value: Binding(
                    get: { Double(selectedSecond) },
                    set: { selectedSecond = Int($0) }
                ),
                in: 0...Double(max(totalSeconds - 1, 0)),
                step: 1
            )
            .tint(Color.corTeal)

            // Start/End labels
            HStack {
                Text("00:00")
                    .font(AppTypography.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(totalDurationLabel)
                    .font(AppTypography.caption)
                    .foregroundStyle(.tertiary)
            }

            // Minute markers (quick-jump buttons showing minutes)
            if totalSeconds > 60 {
                minuteMarkers
            }
        }
    }

    var totalDurationLabel: String {
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // Minute quick-jump buttons
    var minuteMarkers: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(0...totalSeconds / 60, id: \.self) { minute in
                        let secondTarget = minute * 60
                        let isCurrentMinute = selectedSecond / 60 == minute

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedSecond = min(secondTarget, totalSeconds - 1)
                            }
                        } label: {
                            Text("\(minute)m")
                                .font(.system(size: 11, weight: isCurrentMinute ? .bold : .regular))
                                .foregroundStyle(
                                    isCurrentMinute ? .white : Color.corPrimaryText
                                )
                                .frame(width: 36, height: 28)
                                .background(
                                    isCurrentMinute
                                        ? Color.corTeal
                                        : Color.corCardBackground
                                )
                                .clipShape(Capsule())
                                .shadow(
                                    color: .black.opacity(isCurrentMinute ? 0.0 : 0.06),
                                    radius: 2, x: 0, y: 1
                                )
                        }
                        .buttonStyle(.plain)
                        .id(minute)
                    }
                }
                .padding(.horizontal, 2)
            }
            .onChange(of: selectedSecond) { _, _ in
                let currentMinute = selectedSecond / 60
                withAnimation {
                    proxy.scrollTo(currentMinute, anchor: .center)
                }
            }
        }
    }

    // -- Metadata Section (Portrait) --

    var metadataSection: some View {
        RoundedCard {
            VStack(spacing: AppSpacing.sm) {
                metadataRow(icon: "tshirt.fill", label: "Dispositivo", value: session.deviceId)
                Divider()
                metadataRow(icon: "slider.horizontal.3", label: "Filtro", value: session.filterOn ? "ON" : "OFF")
                Divider()
                metadataRow(icon: "clock", label: "Duración", value: session.durationFormatted)
                Divider()
                metadataRow(icon: "waveform.path.ecg", label: "Datos", value: "\(session.fullEcgData.count) segundos")
            }
        }
    }

    // -- Metadata Section Compact (Landscape) --

    var metadataSectionCompact: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Label(session.deviceId, systemImage: "tshirt.fill")
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)

            Label("Filtro: \(session.filterOn ? "ON" : "OFF")", systemImage: "slider.horizontal.3")
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
        }
    }

    func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(AppTypography.captionBold)
                .foregroundStyle(Color.corPrimaryText)
        }
    }
}

// MARK: - Preview

#Preview("Portrait") {
    NavigationStack {
        ECGSessionDetailView(
            session: ECGSession(
                date: Date(),
                durationSeconds: 30,
                deviceId: "Camisa #829",
                filterOn: true,
                status: .normal,
                ecgSamples: ECGDataGenerator.generateStream(complexes: 3, samplesPerComplex: 50),
                fullEcgData: (0..<30).map { sec in
                    ECGSecondSegment(
                        id: sec,
                        samples: ECGDataGenerator.generateStream(complexes: 2, samplesPerComplex: 60)
                    )
                }
            )
        )
    }
}

#Preview("Landscape") {
    NavigationStack {
        ECGSessionDetailView(
            session: ECGSession(
                date: Date(),
                durationSeconds: 120,
                deviceId: "Camisa #829",
                filterOn: true,
                status: .review,
                ecgSamples: ECGDataGenerator.generateStream(complexes: 3, samplesPerComplex: 50),
                fullEcgData: (0..<120).map { sec in
                    ECGSecondSegment(
                        id: sec,
                        samples: ECGDataGenerator.generateStream(complexes: 2, samplesPerComplex: 60)
                    )
                }
            )
        )
    }
    .previewInterfaceOrientation(.landscapeLeft)
}
