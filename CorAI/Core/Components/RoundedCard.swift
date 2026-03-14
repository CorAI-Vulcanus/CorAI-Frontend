import SwiftUI

// MARK: - Rounded Card Container

/// Generic card wrapper with corner radius, shadow, and padding.
struct RoundedCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppSpacing.cardPadding)
            .background(Color.corCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    RoundedCard {
        Text("Sample Card Content")
            .font(AppTypography.body)
    }
    .padding()
    .background(Color.corBackground)
}
