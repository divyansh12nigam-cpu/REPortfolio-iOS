import SwiftUI

struct SignInScreen: View {
    @StateObject private var authManager = AuthManager.shared

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false

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

            Spacer().frame(height: Spacing.widgetsM)

            // Form fields
            VStack(spacing: Spacing.xl) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(Spacing.xxl)
                    .background(Color.surfaceLowContrast)
                    .cornerRadius(Radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(Color.borderSubtle, lineWidth: 1)
                    )

                SecureField("Password", text: $password)
                    .textContentType(isSignUp ? .newPassword : .password)
                    .padding(Spacing.xxl)
                    .background(Color.surfaceLowContrast)
                    .cornerRadius(Radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(Color.borderSubtle, lineWidth: 1)
                    )
            }
            .padding(.horizontal, Spacing.xxxl)

            // Error message
            if let error = authManager.errorMessage {
                Text(error)
                    .font(Typography.bodySmall)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxxl)
                    .padding(.top, Spacing.xl)
            }

            Spacer().frame(height: Spacing.xxxxl)

            // Primary action button
            Button(action: {
                Task {
                    if isSignUp {
                        await authManager.signUp(email: email, password: password)
                    } else {
                        await authManager.signIn(email: email, password: password)
                    }
                }
            }) {
                Group {
                    if authManager.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(Typography.bodyLarge)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(isFormValid ? Color.brandPrimary : Color.brandPrimary.opacity(0.4))
                .cornerRadius(Radius.sm)
            }
            .disabled(!isFormValid || authManager.isLoading)
            .padding(.horizontal, Spacing.xxxl)

            Spacer().frame(height: Spacing.xxl)

            // Toggle sign in / sign up
            Button(action: {
                isSignUp.toggle()
                authManager.errorMessage = nil
            }) {
                Text(isSignUp
                     ? "Already have an account? **Sign in**"
                     : "Don't have an account? **Create one**")
                    .font(Typography.bodySmall)
                    .foregroundColor(.textSecondary)
            }

            Spacer().frame(height: Spacing.xxxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surfaceWhite)
    }

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }
}

#Preview {
    SignInScreen()
}
