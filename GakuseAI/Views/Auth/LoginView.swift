import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingPasswordReset = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.pink.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Logo
                    logoView
                    
                    // Form
                    formSection
                    
                    // Actions
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("ログイン")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showingPasswordReset) {
                PasswordResetView()
            }
            .alert("エラー", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    // MARK: - Logo View
    
    private var logoView: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay {
                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .shadow(color: .pink.opacity(0.3), radius: 10)
            
            Text("GakuseAI")
                .font(.largeTitle.bold())
            
            Text("学習ログを資産に変える")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 16) {
            TextField("メールアドレス", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            
            SecureField("パスワード", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Button {
                showingPasswordReset = true
            } label: {
                Text("パスワードを忘れた場合")
                    .font(.caption)
                    .foregroundColor(.pink)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await viewModel.signIn(email: email, password: password)
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("ログイン")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .disabled(email.isEmpty || password.isEmpty || viewModel.isLoading)
            
            Button {
                showingSignUp = true
            } label: {
                Text("アカウントを作成")
                    .foregroundColor(.pink)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Password Reset View

struct PasswordResetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("メールアドレス") {
                    TextField("email@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Button("リセットメールを送信") {
                        Task {
                            await viewModel.resetPassword(email: email)
                            dismiss()
                        }
                    }
                    .disabled(email.isEmpty || viewModel.isLoading)
                }
            }
            .navigationTitle("パスワードリセット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
