import SwiftUI

// MARK: - History View

struct HistoryView: View {

    @State var viewModel: HistoryViewModel

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    headerSection
                    searchBar
                    filterPills
                    tabSegment
                    sessionsList
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(Color.corBackground.ignoresSafeArea())
            .onAppear { viewModel.onAppear() }
        }
    }
}

// MARK: - Header

private extension HistoryView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Historial")
                .font(AppTypography.largeTitle)
                .foregroundStyle(Color.corPrimaryText)

            Text("Revisa tus sesiones y comparte reportes")
                .font(AppTypography.body)
                .foregroundStyle(.secondary)
        }
        .padding(.top, AppSpacing.sm)
    }
}

// MARK: - Search Bar

private extension HistoryView {
    var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)

            TextField("Buscar por fecha, nota...", text: $viewModel.searchText)
                .font(AppTypography.body)
                .foregroundStyle(Color.corPrimaryText)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 12)
        .background(Color.corSearchBarBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Filter Pills

private extension HistoryView {
    var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(HistoryFilter.allCases, id: \.self) { filter in
                    Button {
                        viewModel.filterChanged(to: filter)
                    } label: {
                        Text(filter.rawValue)
                            .font(AppTypography.captionBold)
                            .foregroundStyle(
                                viewModel.selectedFilter == filter ? .white : Color.corPrimaryText
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedFilter == filter
                                    ? Color.corPrimaryDarkBlue
                                    : Color.corCardBackground
                            )
                            .clipShape(Capsule())
                            .shadow(
                                color: .black.opacity(viewModel.selectedFilter == filter ? 0.0 : 0.06),
                                radius: 4, x: 0, y: 2
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Tab Segment

private extension HistoryView {
    var tabSegment: some View {
        Picker("", selection: $viewModel.selectedTab) {
            ForEach(HistoryTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - Sessions List

private extension HistoryView {
    @ViewBuilder
    var sessionsList: some View {
        if viewModel.isLoading {
            HStack {
                Spacer()
                ProgressView()
                    .padding(.top, AppSpacing.xl)
                Spacer()
            }
        } else if let errorMessage = viewModel.errorMessage {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, AppSpacing.xl)
        } else {
            ForEach(viewModel.dateGroups) { group in
                sectionView(group)
            }
        }
    }

    func sectionView(_ group: HistoryDateGroup) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(group.title)
                .font(AppTypography.headline)
                .foregroundStyle(Color.corPrimaryText)
                .padding(.top, AppSpacing.sm)

            ForEach(group.sessions) { session in
                if session.isArchived {
                    ECGHistoryCardView(session: session, viewModel: viewModel)
                } else {
                    NavigationLink(destination: ECGSessionDetailView(session: session)) {
                        ECGHistoryCardView(session: session, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HistoryView(viewModel: HistoryViewModel())
}
