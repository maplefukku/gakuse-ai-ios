import Foundation
import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
    init() {
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Session Check
    
    func checkSession() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let session = try await authService.restoreSession() {
                isAuthenticated = true
                currentUser = session.user
            } else {
                isAuthenticated = false
                currentUser = nil
            }
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let user = try await authService.signUp(
                email: email,
                password: password,
                name: name
            )
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let session = try await authService.signIn(
                email: email,
                password: password
            )
            currentUser = session.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await authService.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await authService.resetPassword(email: email)
            // 成功メッセージを表示
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
