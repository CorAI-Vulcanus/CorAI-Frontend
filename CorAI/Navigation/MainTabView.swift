import SwiftUI

// MARK: - Main Tab View

struct MainTabView: View {

    @State private var selectedTab: Tab = .live
    @State private var showRecording = false
    @State private var sessionStore = SessionStore()

    // Dependency injection: repository flows through to ViewModel
    let repository: HomeRepositoryProtocol

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            tabContent
                .padding(.bottom, 60) // space for custom tab bar

            // Custom tab bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $showRecording) {
            recordingSheet
        }
    }

    // MARK: - Tab Enum

    enum Tab: Int, CaseIterable {
        case live, history, doctor, profile

        var title: String {
            switch self {
            case .live:    return "Live"
            case .history: return "Historial"
            case .doctor:  return "Doctor"
            case .profile: return "Perfil"
            }
        }

        var icon: String {
            switch self {
            case .live:    return "waveform.path.ecg"
            case .history: return "clock.arrow.circlepath"
            case .doctor:  return "stethoscope"
            case .profile: return "person.fill"
            }
        }
    }
}

// MARK: - Tab Content

private extension MainTabView {
    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .live:
            HomeView(viewModel: HomeViewModel(repository: repository))
        case .history:
            HistoryView(viewModel: HistoryViewModel(
                repository: HistoryRepository(),
                sessionStore: sessionStore
            ))
        case .doctor:
            DoctorView()
        case .profile:
            ProfileView()
        }
    }

    func placeholderView(title: String, icon: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.corTeal.opacity(0.4))
            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(Color.corPrimaryText.opacity(0.5))
            Text("Coming soon")
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.corBackground.ignoresSafeArea())
    }
}

// MARK: - Recording Sheet

private extension MainTabView {
    var recordingSheet: some View {
        let vm = RecordingViewModel()
        vm.onSessionSaved = { session in
            sessionStore.add(session)
            // Auto-switch to history tab after recording
            selectedTab = .history
        }
        return RecordingView(viewModel: vm)
    }
}

// MARK: - Custom Tab Bar

private extension MainTabView {
    var customTabBar: some View {
        HStack {
            // Left tabs
            tabButton(.live)
            tabButton(.history)

            Spacer()

            // Center action button (start recording)
            centerButton

            Spacer()

            // Right tabs
            tabButton(.doctor)
            tabButton(.profile)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.xs)
        .background(
            Color.corCardBackground
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    func tabButton(_ tab: Tab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundStyle(selectedTab == tab ? Color.corTeal : .gray)

                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(selectedTab == tab ? Color.corTeal : .gray)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    var centerButton: some View {
        Button {
            showRecording = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.corTeal, Color.corLightTeal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: Color.corTeal.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .offset(y: -20)
    }
}

// MARK: - Preview

#Preview {
    MainTabView(repository: MockHomeRepository())
}
