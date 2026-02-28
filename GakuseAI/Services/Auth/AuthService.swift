import Foundation
import Supabase

/// 認証サービス
actor AuthService {
    static let shared = AuthService()
    
    private let supabase = SupabaseManager.shared
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, name: String) async throws -> User {
        do {
            let response = try await supabase.client.auth.signUp(
                email: email,
                password: password,
                data: ["name": .string(name)]
            )
            
            guard let user = response.user else {
                throw AuthError.signupFailed
            }
            
            return user
        } catch {
            throw mapError(error)
        }
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async throws -> Session {
        do {
            let session = try await supabase.client.auth.signIn(
                email: email,
                password: password
            )
            return session
        } catch {
            throw mapError(error)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async throws {
        try await supabase.client.auth.signOut()
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async throws {
        try await supabase.client.auth.resetPasswordForEmail(email)
    }
    
    // MARK: - Session Management
    
    func restoreSession() async throws -> Session? {
        do {
            let session = try await supabase.client.auth.session
            return session
        } catch {
            return nil
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapError(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }
        
        let errorString = error.localizedDescription.lowercased()
        
        if errorString.contains("invalid login credentials") {
            return .invalidCredentials
        } else if errorString.contains("email not confirmed") {
            return .emailNotConfirmed
        } else if errorString.contains("user already registered") {
            return .userAlreadyExists
        } else if errorString.contains("password") {
            return .weakPassword
        } else if errorString.contains("email") {
            return .invalidEmail
        }
        
        return .unknown(error.localizedDescription)
    }
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case signupFailed
    case invalidCredentials
    case emailNotConfirmed
    case userAlreadyExists
    case weakPassword
    case invalidEmail
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .signupFailed:
            return "サインアップに失敗しました"
        case .invalidCredentials:
            return "メールアドレスまたはパスワードが間違っています"
        case .emailNotConfirmed:
            return "メールアドレスの確認が必要です"
        case .userAlreadyExists:
            return "このメールアドレスは既に使用されています"
        case .weakPassword:
            return "パスワードが弱すぎます（8文字以上必要）"
        case .invalidEmail:
            return "無効なメールアドレスです"
        case .unknown(let message):
            return message
        }
    }
}
