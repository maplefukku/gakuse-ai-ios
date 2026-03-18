import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AuthViewModel()

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingTerms = false
    @State private var isSignUpButtonPressed = false

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
        .drawingGroup()
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
            PasswordStrengthView(password: password)

            // Terms
            SignUpTermsView(showingTerms: $showingTerms)
        }
        .padding(.horizontal)
        .drawingGroup()
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
            .scaleEffect(isSignUpButtonPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isSignUpButtonPressed)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                withAnimation {
                    isSignUpButtonPressed = pressing
                }
            }, perform: {})
        }
        .padding(.horizontal)
        .drawingGroup()
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        password.count >= 8 &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        isValidEmail(email)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    SignUpView()
}
