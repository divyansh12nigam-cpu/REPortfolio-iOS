import SwiftUI
import AuthenticationServices
import Supabase

/// Authentication state for the app.
enum AuthState: Equatable {
    case loading
    case signedOut
    case signedIn(userId: String)
}

/// Manages Sign in with Apple → Supabase Auth flow.
@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var authState: AuthState = .loading
    @Published var errorMessage: String?

    /// True when user chose "Continue without signing in" — skips cloud sync.
    var isOffline: Bool { currentUserId == "offline" }

    private var authListener: Task<Void, Never>?

    private init() {
        listenForAuthChanges()
    }

    deinit {
        authListener?.cancel()
    }

    // MARK: - Session restoration

    /// Check for an existing Supabase session on app launch.
    func checkSession() async {
        do {
            let session = try await SupabaseManager.client.auth.session
            authState = .signedIn(userId: session.user.id.uuidString)
            print("[Auth] Restored session for user: \(session.user.id)")
        } catch {
            print("[Auth] No existing session: \(error.localizedDescription)")
            authState = .signedOut
        }
    }

    // MARK: - Sign in with Apple (via SignInWithAppleButton result)

    /// Handle the result from SwiftUI's `SignInWithAppleButton` completion.
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        errorMessage = nil

        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Unexpected credential type."
                return
            }
            guard let identityToken = credential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                errorMessage = "Failed to get Apple identity token."
                return
            }

            do {
                let session = try await SupabaseManager.client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: tokenString
                    )
                )
                authState = .signedIn(userId: session.user.id.uuidString)
                print("[Auth] Signed in: \(session.user.id)")
            } catch {
                print("[Auth] Supabase sign in failed: \(error)")
                errorMessage = "Sign in failed. Please try again."
            }

        case .failure(let error):
            if let asError = error as? ASAuthorizationError, asError.code == .canceled {
                print("[Auth] User canceled Sign in with Apple")
                return
            }
            print("[Auth] Apple sign in failed: \(error)")
            errorMessage = "Sign in failed. Please try again."
        }
    }

    // MARK: - Offline mode

    /// Skip sign-in and continue with local-only data.
    func continueOffline() {
        authState = .signedIn(userId: "offline")
    }

    // MARK: - Sign out

    func signOut() async {
        if !isOffline {
            do {
                try await SupabaseManager.client.auth.signOut()
            } catch {
                print("[Auth] Sign out error: \(error)")
            }
        }
        authState = .signedOut
    }

    // MARK: - Current user

    var currentUserId: String? {
        if case .signedIn(let userId) = authState { return userId }
        return nil
    }

    // MARK: - Private

    private func listenForAuthChanges() {
        authListener = Task { [weak self] in
            for await (event, session) in SupabaseManager.client.auth.authStateChanges {
                guard let self else { return }
                switch event {
                case .signedIn:
                    if let user = session?.user {
                        self.authState = .signedIn(userId: user.id.uuidString)
                    }
                case .signedOut:
                    self.authState = .signedOut
                default:
                    break
                }
            }
        }
    }
}
