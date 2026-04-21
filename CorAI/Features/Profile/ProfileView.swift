import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.corBackground.ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Cargando perfil…")
                } else {
                    ScrollView {
                        VStack(spacing: AppSpacing.lg) {
                            avatarSection
                            infoCard
                            if viewModel.isEditing { editCard }
                            logoutButton
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.isEditing ? "Cancelar" : "Editar") {
                        withAnimation { viewModel.isEditing.toggle() }
                    }
                    .foregroundStyle(Color.corTeal)
                }
            }
            .task { await viewModel.load() }
        }
    }

    // MARK: - Avatar

    private var avatarSection: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.corPrimaryDarkBlue)
                    .frame(width: 80, height: 80)
                Text(viewModel.initials)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            if let name = viewModel.profile?.name, !name.isEmpty {
                Text(name)
                    .font(AppTypography.title)
                    .foregroundStyle(Color.corPrimaryText)
            }
            Text(viewModel.roleLabel)
                .font(AppTypography.callout)
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(Color.corTeal)
                .clipShape(Capsule())
        }
        .padding(.top, AppSpacing.md)
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            profileRow(icon: "person.fill",      label: "Usuario",  value: viewModel.profile?.username ?? "—")
            Divider().padding(.leading, 44)
            profileRow(icon: "envelope.fill",    label: "Email",    value: viewModel.profile?.email ?? "—")
            Divider().padding(.leading, 44)
            profileRow(icon: "checkmark.shield.fill", label: "Estado",
                       value: viewModel.profile?.is_active == true ? "Activo" : "Inactivo",
                       valueColor: viewModel.profile?.is_active == true ? Color.corStatusGreen : Color.gray)
        }
        .background(Color.corCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func profileRow(
        icon: String, label: String, value: String,
        valueColor: Color = Color.corPrimaryText
    ) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .foregroundStyle(Color.corTeal)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.corSecondaryText)
                Text(value)
                    .font(AppTypography.body)
                    .foregroundStyle(valueColor)
            }
            Spacer()
        }
        .padding(AppSpacing.md)
    }

    // MARK: - Edit Card

    private var editCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Editar información")
                .font(AppTypography.headline)
                .foregroundStyle(Color.corPrimaryText)

            editField(icon: "person.text.rectangle.fill", placeholder: "Nombre",
                      text: $viewModel.editName, contentType: .name)
            editField(icon: "envelope.fill", placeholder: "Email",
                      text: $viewModel.editEmail, contentType: .emailAddress)
            editField(icon: "phone.fill", placeholder: "Teléfono",
                      text: $viewModel.editPhone, contentType: .telephoneNumber)

            if let err = viewModel.errorMessage {
                Text(err).font(AppTypography.caption).foregroundStyle(.red)
            }
            if let ok = viewModel.successMessage {
                Text(ok).font(AppTypography.caption).foregroundStyle(Color.corStatusGreen)
            }

            Button {
                Task { await viewModel.saveChanges() }
            } label: {
                Group {
                    if viewModel.isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Guardar cambios").font(AppTypography.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.corPrimaryDarkBlue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isSaving)
        }
        .padding(AppSpacing.lg)
        .background(Color.corCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func editField(
        icon: String, placeholder: String,
        text: Binding<String>, contentType: UITextContentType
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon).foregroundStyle(Color.corTeal).frame(width: 20)
            TextField(placeholder, text: text)
                .textContentType(contentType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(contentType == .emailAddress ? .never : .words)
        }
        .padding(AppSpacing.md)
        .background(Color.corBackgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button(role: .destructive) {
            viewModel.logout()
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Cerrar sesión")
                    .font(AppTypography.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.red.opacity(0.1))
            .foregroundStyle(.red)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.bottom, AppSpacing.lg)
    }
}
