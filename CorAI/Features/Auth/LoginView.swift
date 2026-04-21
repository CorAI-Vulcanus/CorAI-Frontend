import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @State private var showRegister = false

    var body: some View {
        ZStack {
            Color.corBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    Spacer().frame(height: AppSpacing.xxl)

                    // MARK: Logo
                    VStack(spacing: AppSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(Color.corPrimaryDarkBlue)
                                .frame(width: 88, height: 88)
                            Image(systemName: "waveform.path.ecg.rectangle")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(Color.corTeal)
                        }
                        Text("CorAI")
                            .font(AppTypography.largeTitle)
                            .foregroundStyle(Color.corPrimaryDarkBlue)
                        Text("Monitor cardíaco inteligente")
                            .font(AppTypography.callout)
                            .foregroundStyle(Color.corSecondaryText)
                    }

                    // MARK: Form Card
                    VStack(spacing: AppSpacing.md) {
                        if showRegister {
                            registerFields
                        }

                        // Campos comunes
                        inputField(
                            icon: "person.fill",
                            placeholder: "Usuario",
                            text: $viewModel.username,
                            contentType: .username
                        )

                        SecureInputField(
                            icon: "lock.fill",
                            placeholder: "Contraseña",
                            text: $viewModel.password
                        )

                        if let msg = viewModel.errorMessage {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text(msg)
                            }
                            .font(AppTypography.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.sm)
                        }

                        // MARK: Primary button
                        Button {
                            Task {
                                if showRegister {
                                    await viewModel.signIn()
                                } else {
                                    await viewModel.login()
                                }
                            }
                        } label: {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(showRegister ? "Crear cuenta" : "Iniciar sesión")
                                        .font(AppTypography.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.corPrimaryDarkBlue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius))
                        }
                        .disabled(viewModel.isLoading)

                        // MARK: Toggle login / register
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showRegister.toggle()
                                viewModel.errorMessage = nil
                            }
                        } label: {
                            Text(showRegister ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate")
                                .font(AppTypography.callout)
                                .foregroundStyle(Color.corTeal)
                        }
                    }
                    .padding(AppSpacing.lg)
                    .background(Color.corCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, AppSpacing.md)

                    Spacer().frame(height: AppSpacing.xxl)
                }
            }
        }
    }

    // MARK: - Register extra fields

    @ViewBuilder
    private var registerFields: some View {
        inputField(
            icon: "person.text.rectangle.fill",
            placeholder: "Nombre completo",
            text: $viewModel.signInName,
            contentType: .name
        )
        inputField(
            icon: "envelope.fill",
            placeholder: "Correo electrónico",
            text: $viewModel.signInEmail,
            contentType: .emailAddress
        )
        inputField(
            icon: "phone.fill",
            placeholder: "Teléfono",
            text: $viewModel.signInPhone,
            contentType: .telephoneNumber
        )

        // Role picker
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Rol")
                .font(AppTypography.caption)
                .foregroundStyle(Color.corSecondaryText)
                .padding(.leading, AppSpacing.sm)

            HStack(spacing: AppSpacing.sm) {
                ForEach(["Patient", "Doctor"], id: \.self) { role in
                    Button {
                        viewModel.signInRole = role
                    } label: {
                        Text(role == "Patient" ? "Paciente" : "Doctor")
                            .font(AppTypography.callout)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(viewModel.signInRole == role
                                        ? Color.corPrimaryDarkBlue
                                        : Color.corBackgroundGray)
                            .foregroundStyle(viewModel.signInRole == role ? .white : Color.corPrimaryText)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    // MARK: - Reusable input field

    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        contentType: UITextContentType
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(Color.corTeal)
                .frame(width: 20)
            TextField(placeholder, text: text)
                .textContentType(contentType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(
                    contentType == .emailAddress ? .never : .words
                )
        }
        .padding(AppSpacing.md)
        .background(Color.corBackgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Secure field helper (icon + SecureField)

private struct SecureInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(Color.corTeal)
                .frame(width: 20)
            SecureField(placeholder, text: $text)
                .textContentType(.password)
        }
        .padding(AppSpacing.md)
        .background(Color.corBackgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
