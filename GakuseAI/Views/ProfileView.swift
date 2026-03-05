import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingEditProfile = false
    @State private var showingThemePicker = false
    @State private var showingLogoutConfirmation = false
    @State private var showingDeleteDataConfirmation = false
    @State private var isDeletingData = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    Button {
                        showingEditProfile = true
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
                                    Text(viewModel.userProfile?.name.first?.uppercased() ?? "U")
                                        .font(.title.bold())
                                        .foregroundColor(.white)
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.userProfile?.name ?? "ユーザー")
                                    .font(.headline)
                                
                                if let email = viewModel.userProfile?.email {
                                    Text(email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("メールアドレス未設定")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                        .foregroundColor(.primary)
                    }
                }
                
                // Settings Section
                Section("設定") {
                    Toggle("通知", isOn: Binding(
                        get: { viewModel.userProfile?.settings.notificationsEnabled ?? true },
                        set: { newValue in
                            Task {
                                var settings = viewModel.userProfile?.settings ?? UserSettings()
                                settings.notificationsEnabled = newValue
                                await viewModel.updateSettings(settings)
                            }
                        }
                    ))
                    
                    Toggle("自動保存", isOn: Binding(
                        get: { viewModel.userProfile?.settings.autoSaveEnabled ?? true },
                        set: { newValue in
                            Task {
                                var settings = viewModel.userProfile?.settings ?? UserSettings()
                                settings.autoSaveEnabled = newValue
                                await viewModel.updateSettings(settings)
                            }
                        }
                    ))
                    
                    Button {
                        showingThemePicker = true
                    } label: {
                        HStack {
                            Text("テーマ")
                            Spacer()
                            Text(themeName)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Data Section
                Section("データ") {
                    NavigationLink("学習ログをエクスポート") {
                        ExportView()
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteDataConfirmation = true
                    } label: {
                        HStack {
                            if isDeletingData {
                                ProgressView()
                            }
                            Text("すべてのデータを削除")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                    .disabled(isDeletingData)
                }
                
                // About Section
                Section("その他") {
                    Link("利用規約", destination: URL(string: "https://gakuse.ai/terms")!)
                    Link("プライバシーポリシー", destination: URL(string: "https://gakuse.ai/privacy")!)
                    Link("ヘルプ", destination: URL(string: "https://gakuse.ai/help")!)
                    
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Logout Section
                Section {
                    Button("ログアウト", role: .destructive) {
                        showingLogoutConfirmation = true
                    }
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingThemePicker) {
                ThemePickerView(viewModel: viewModel)
            }
            .alert("ログアウトしますか？", isPresented: $showingLogoutConfirmation) {
                Button("キャンセル", role: .cancel) {}
                Button("ログアウト", role: .destructive) {
                    Task {
                        await authViewModel.signOut()
                    }
                }
            } message: {
                Text("アカウントからログアウトします。学習データは保存されます。")
            }
            .alert("すべてのデータを削除しますか？", isPresented: $showingDeleteDataConfirmation) {
                Button("キャンセル", role: .cancel) {}
                Button("削除", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("この操作は取り消せません。学習ログ、プロファイル、チャット履歴がすべて削除されます。")
            }
        }
    }
    
    private var themeName: String {
        switch viewModel.userProfile?.settings.theme {
        case .system:
            return "システム"
        case .light:
            return "ライト"
        case .dark:
            return "ダーク"
        case .none:
            return "システム"
        }
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    private func deleteAllData() {
        isDeletingData = true
        Task {
            try? await PersistenceService.shared.deleteAllData()
            await viewModel.loadProfile()
            isDeletingData = false
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("プロフィール") {
                    TextField("名前", text: $name)
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
                            await viewModel.updateProfile(name: name)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = viewModel.userProfile?.name ?? ""
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
                ForEach([AppTheme.system, .light, .dark], id: \.self) { theme in
                    Button {
                        selectedTheme = theme
                        Task {
                            var settings = viewModel.userProfile?.settings ?? UserSettings()
                            settings.theme = theme
                            await viewModel.updateSettings(settings)
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
            .navigationTitle("テーマ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
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
        case .system:
            return "システム"
        case .light:
            return "ライト"
        case .dark:
            return "ダーク"
        }
    }
}

// MARK: - Export View

struct ExportView: View {
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showShareSheet = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    private let persistence = PersistenceService.shared
    
    var body: some View {
        List {
            Section {
                Button {
                    exportAsJSON()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.pink)
                        Text("JSONでエクスポート")
                        Spacer()
                        if isExporting {
                            ProgressView()
                        }
                    }
                }
                .disabled(isExporting)
                
                Button {
                    // PDF形式は将来実装予定
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.gray)
                        Text("PDFでエクスポート（準備中）")
                    }
                }
                .disabled(true)
            }
            
            Section {
                Text("学習ログ、プロファイル、チャット履歴をJSON形式でエクスポートします。他のデバイスやサービスへの移行に利用できます。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("エクスポート")
        .sheet(isPresented: $showShareSheet) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "不明なエラーが発生しました")
        }
    }
    
    private func exportAsJSON() {
        isExporting = true
        Task {
            do {
                let url = try await persistence.exportAllData()
                exportURL = url
                showShareSheet = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isExporting = false
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
