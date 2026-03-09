import SwiftUI
import Supabase

/// Authentication state for the app.
enum AuthState: Equatable {
    case loading
    case signedOut
    case signedIn(userId: String)
}

/// Manages email/password authentication via Supabase Auth.
@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var authState: AuthState = .loading
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

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

    // MARK: - Email/Password Auth

    /// Create a new account with email and password.
    func signUp(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await SupabaseManager.client.auth.signUp(
                email: email,
                password: password
            )
            authState = .signedIn(userId: result.user.id.uuidString)
            print("[Auth] Signed up: \(result.user.id)")
        } catch {
            print("[Auth] Sign up failed: \(error)")
            errorMessage = parseAuthError(error)
        }
    }

    /// Sign in with existing email and password.
    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await SupabaseManager.client.auth.signIn(
                email: email,
                password: password
            )
            authState = .signedIn(userId: session.user.id.uuidString)
            print("[Auth] Signed in: \(session.user.id)")
        } catch {
            print("[Auth] Sign in failed: \(error)")
            errorMessage = parseAuthError(error)
        }
    }

    // MARK: - Sign out

    func signOut() async {
        do {
            try await SupabaseManager.client.auth.signOut()
        } catch {
            print("[Auth] Sign out error: \(error)")
        }
        authState = .signedOut
    }

    // MARK: - Current user

    var currentUserId: String? {
        if case .signedIn(let userId) = authState { return userId }
        return nil
    }

    /// The signed-in user's email, read from the current Supabase session.
    var currentUserEmail: String? {
        try? SupabaseManager.client.auth.currentSession?.user.email
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

    private func parseAuthError(_ error: Error) -> String {
        let message = error.localizedDescription.lowercased()
        if message.contains("invalid login") || message.contains("invalid_credentials") {
            return "Incorrect email or password."
        } else if message.contains("already registered") || message.contains("already been registered") {
            return "This email is already registered. Try signing in."
        } else if message.contains("password") && message.contains("short") {
            return "Password must be at least 6 characters."
        } else if message.contains("invalid email") || message.contains("not a valid") {
            return "Please enter a valid email address."
        }
        return "Something went wrong. Please try again."
    }
}
