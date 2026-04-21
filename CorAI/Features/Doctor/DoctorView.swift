import SwiftUI

struct DoctorView: View {
    @State private var viewModel = DoctorViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.corBackground.ignoresSafeArea()

                Group {
                    if viewModel.isLoading {
                        ProgressView("Cargando pacientes…")
                    } else if let err = viewModel.errorMessage {
                        errorView(message: err)
                    } else if viewModel.patients.isEmpty {
                        emptyView
                    } else {
                        patientList
                    }
                }
            }
            .navigationTitle("Pacientes")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Buscar paciente")
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
        }
    }

    // MARK: - Patient List

    private var patientList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(viewModel.filtered) { patient in
                    NavigationLink(value: patient) {
                        PatientRowView(patient: patient)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.md)
        }
        .navigationDestination(for: PatientSummary.self) { patient in
            PatientDetailView(userId: patient.user_id)
        }
    }

    // MARK: - Empty / Error

    private var emptyView: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.corTeal.opacity(0.4))
            Text("Sin pacientes")
                .font(AppTypography.title)
                .foregroundStyle(Color.corPrimaryText.opacity(0.5))
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.corStatusReview)
            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(Color.corSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            Button("Reintentar") { Task { await viewModel.load() } }
                .foregroundStyle(Color.corTeal)
        }
    }
}

// MARK: - Patient Row

struct PatientRowView: View {
    let patient: PatientSummary

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Avatar
            ZStack {
                Circle().fill(Color.corHRVIconBg).frame(width: 44, height: 44)
                Image(systemName: "person.fill")
                    .foregroundStyle(Color.corPrimaryDarkBlue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("ID: \(patient.user_id.prefix(8))…")
                    .font(AppTypography.headline)
                    .foregroundStyle(Color.corPrimaryText)

                HStack(spacing: AppSpacing.sm) {
                    if let bt = patient.blood_type {
                        tag(text: bt, color: .red)
                    }
                    if let sex = patient.sex {
                        tag(text: sex, color: .corTeal)
                    }
                    if let w = patient.weight {
                        tag(text: "\(Int(w)) kg", color: .gray)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(AppSpacing.md)
        .background(Color.corCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private func tag(text: String, color: Color) -> some View {
        Text(text)
            .font(AppTypography.captionBold)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

// MARK: - Patient Detail

struct PatientDetailView: View {
    let userId: String
    @State private var detail: PatientDetail?
    @State private var isLoading = true
    @State private var error: String?

    private let repository = DoctorRepository()

    var body: some View {
        ZStack {
            Color.corBackground.ignoresSafeArea()
            if isLoading {
                ProgressView()
            } else if let err = error {
                Text(err).foregroundStyle(.red).padding()
            } else if let d = detail {
                detailContent(d)
            }
        }
        .navigationTitle(detail?.name ?? "Paciente")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                detail = try await repository.fetchPatientDetail(userId: userId)
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func detailContent(_ d: PatientDetail) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Header
                VStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle().fill(Color.corPrimaryDarkBlue).frame(width: 72, height: 72)
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
                    }
                    Text(d.name ?? d.username ?? "—")
                        .font(AppTypography.title)
                    if let email = d.email {
                        Text(email)
                            .font(AppTypography.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top)

                // Data card
                VStack(alignment: .leading, spacing: 0) {
                    row(label: "Tipo de sangre", value: d.blood_type ?? "—")
                    Divider().padding(.leading, AppSpacing.md)
                    row(label: "Sexo",           value: d.sex ?? "—")
                    Divider().padding(.leading, AppSpacing.md)
                    row(label: "Peso",           value: d.weight.map { "\(Int($0)) kg" } ?? "—")
                    Divider().padding(.leading, AppSpacing.md)
                    row(label: "Altura",         value: d.height.map { "\(Int($0)) cm" } ?? "—")
                }
                .background(Color.corCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
                .shadow(color: .black.opacity(0.05), radius: 8)
                .padding(.horizontal, AppSpacing.md)
            }
        }
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppTypography.callout)
                .foregroundStyle(Color.corSecondaryText)
            Spacer()
            Text(value)
                .font(AppTypography.headline)
                .foregroundStyle(Color.corPrimaryText)
        }
        .padding(AppSpacing.md)
    }
}
