import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AuthViewModel()
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingTerms = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.pink.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Form
                        formSection
                        
                        // Actions
                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("アカウント作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
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
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.pink)
            
            Text("新規登録")
                .font(.title2.bold())
            
            Text("学習の旅を始めましょう")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 16) {
            TextField("名前", text: $name)
                .textFieldStyle(.roundedBorder)
            
            TextField("メールアドレス", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            
            SecureField("パスワード（8文字以上）", text: $password)
                .textFieldStyle(.roundedBorder)
            
            SecureField("パスワード確認", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
            
            // Password strength indicator
            passwordStrengthView
            
            // Terms
            termsView
        }
        .padding(.horizontal)
    }
    
    // MARK: - Password Strength
    
    private var passwordStrengthView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { index in
                    Rectangle()
                        .fill(passwordStrengthColor(for: index))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            
            Text(passwordStrengthText)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    private func passwordStrengthColor(for index: Int) -> Color {
        let strength = passwordStrength
        if index < strength {
            switch strength {
            case 1: return .red
            case 2: return .orange
            case 3: return .yellow
            case 4: return .green
            default: return .gray.opacity(0.3)
            }
        }
        return .gray.opacity(0.3)
    }
    
    private var passwordStrength: Int {
        guard !password.isEmpty else { return 0 }
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.contains(where: { $0.isUppercase }) { score += 1 }
        if password.contains(where: { $0.isNumber }) { score += 1 }
        if password.contains(where: { !$0.isLetter && !$0.isNumber }) { score += 1 }
        return score
    }
    
    private var passwordStrengthText: String {
        switch passwordStrength {
        case 0: return ""
        case 1: return "弱い"
        case 2: return "普通"
        case 3: return "強い"
        case 4: return "非常に強い"
        default: return ""
        }
    }
    
    // MARK: - Terms View
    
    private var termsView: some View {
        VStack(spacing: 8) {
            Text("アカウントを作成することで、以下に同意したことになります：")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Button {
                    showingTerms = true
                } label: {
                    Text("利用規約")
                        .font(.caption)
                        .underline()
                        .foregroundColor(.pink)
                }
                
                Text("と")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button {
                    showingTerms = true
                } label: {
                    Text("プライバシーポリシー")
                        .font(.caption)
                        .underline()
                        .foregroundColor(.pink)
                }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await viewModel.signUp(
                        email: email,
                        password: password,
                        name: name
                    )
                    
                    if viewModel.isAuthenticated {
                        dismiss()
                    }
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("アカウントを作成")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .disabled(!isFormValid || viewModel.isLoading)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Validation
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword
    }
}

#Preview {
    SignUpView()
}
