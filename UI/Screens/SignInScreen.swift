import SwiftUI
import AuthenticationServices

struct SignInScreen: View {
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Branding
            VStack(spacing: Spacing.xxl) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.brandPrimary)

                Text("REPortfolio")
                    .font(Typography.priceLabel)
                    .foregroundColor(.textPrimary)

                Text("Track your real estate wealth")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Error message
            if let error = authManager.errorMessage {
                Text(error)
                    .font(Typography.bodySmall)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxxl)
                    .padding(.bottom, Spacing.xxl)
            }

            // Sign in with Apple button
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                Task { await authManager.handleAppleSignIn(result: result) }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(Radius.sm)
            .padding(.horizontal, Spacing.xxxl)

            Spacer().frame(height: Spacing.xxxxl)

            // Skip for now
            Button(action: {
                authManager.continueOffline()
            }) {
                Text("Continue without signing in")
                    .font(Typography.bodySmall)
                    .foregroundColor(.textSecondary)
                    .underline()
            }
            .padding(.bottom, Spacing.widgetsM)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surfaceWhite)
    }
}

#Preview {
    SignInScreen()
}
