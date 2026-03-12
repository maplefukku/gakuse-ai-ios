import SwiftUI

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var name = ""
    @State private var email = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("アバター") {
                    NavigationLink {
                        AvatarPickerView(viewModel: viewModel)
                    } label: {
                        HStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.pink, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .overlay {
                                    if let avatarIcon = viewModel.userProfile?.avatarIcon {
                                        Image(systemName: avatarIcon)
                                            .font(.title)
                                            .foregroundColor(.white)
                                    } else {
                                        Text(viewModel.userProfile?.name.first?.uppercased() ?? "U")
                                            .font(.title.bold())
                                            .foregroundColor(.white)
                                    }
                                }

                            VStack(alignment: .leading) {
                                Text("アバター")
                                Text("アイコンを選択")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }

                Section("名前") {
                    TextField("名前", text: $name)
                }

                Section("メールアドレス") {
                    TextField("メールアドレス", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await viewModel.updateProfile(name: name, email: email.isEmpty ? nil : email)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = viewModel.userProfile?.name ?? ""
                email = viewModel.userProfile?.email ?? ""
            }
        }
    }
}

// MARK: - Theme Picker View

struct ThemePickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var selectedTheme: AppTheme = .system

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach([AppTheme.system, .light, .dark], id: \.self) { theme in
                        Button {
                            selectedTheme = theme
                            Task {
                                await viewModel.updateTheme(theme)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Text(themeName(for: theme))
                                Spacer()
                                if selectedTheme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.pink)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }

                Section {
                    Text("カラフルなテーマは「外観」設定で選択できます。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("テーマ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                selectedTheme = viewModel.userProfile?.settings.theme ?? .system
            }
        }
    }

    private func themeName(for theme: AppTheme) -> String {
        switch theme {
        case .system: return "システム"
        case .light: return "ライト"
        case .dark: return "ダーク"
        default: return theme.displayName
        }
    }
}
