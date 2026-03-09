import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingEditProfile = false
    @State private var showingThemePicker = false
    @State private var showingAvatarPicker = false
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
                        ProfileButtonContent(
                            profile: viewModel.userProfile
                        )
                    }
                    .accessibilityIdentifier("profileEditButton")
                    .accessibilityLabel("プロフィール編集")
                    .accessibilityHint("プロフィール情報を編集できます")
                    .buttonStyle(PlainButtonStyle())
                }

                // Settings Section
                Section("設定") {
                    // Notifications
                    NavigationLink {
                        NotificationSettingsView(viewModel: viewModel)
                    } label: {
                        SettingRow(
                            icon: "bell.fill",
                            title: "通知",
                            showChevron: viewModel.userProfile?.settings.notificationsEnabled == true
                        )
                    }
                    .accessibilityIdentifier("notificationsSetting")
                    .accessibilityLabel("通知設定")

                    // Appearance
                    NavigationLink {
                        AppearanceSettingsView(viewModel: viewModel)
                    } label: {
                        SettingRow(
                            icon: "paintbrush.fill",
                            title: "外観",
                            showChevron: true
                        )
                    }
                    .accessibilityIdentifier("appearanceSetting")
                    .accessibilityLabel("外観設定")

                    // Language
                    NavigationLink {
                        LanguageSettingsView(viewModel: viewModel)
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.pink)
                                .frame(width: 24)
                            Text("言語")
                            Spacer()
                            Text(languageDisplayName)
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .accessibilityIdentifier("languageSetting")
                    .accessibilityLabel("言語設定")
                }
                // Data Section
                Section("データ") {
                    NavigationLink {
                        DataExportView(viewModel: viewModel)
                    } label: {
                        SettingRow(
                            icon: "square.and.arrow.up",
                            title: "学習ログをエクスポート",
                            showChevron: true
                        )
                    }
                    .accessibilityIdentifier("exportDataButton")
                    .accessibilityLabel("学習ログをエクスポート")
                    .accessibilityHint("CSVまたはJSON形式でエクスポートできます")

                    Button(role: .destructive) {
                        showingDeleteDataConfirmation = true
                    } label: {
                        HStack {
                            if isDeletingData {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text("すべてのデータを削除")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                    .disabled(isDeletingData)
                    .accessibilityIdentifier("deleteAllDataButton")
                    .accessibilityLabel("すべてのデータを削除")
                    .accessibilityHint("すべての学習データが削除されます")
                }

                // About Section
                Section("その他") {
                    Link("利用規約", destination: URL(string: "https://gakuse.ai/terms")!)
                        .accessibilityIdentifier("termsOfService")
                        .accessibilityLabel("利用規約")
                    Link("プライバシーポリシー", destination: URL(string: "https://gakuse.ai/privacy")!)
                        .accessibilityIdentifier("privacyPolicy")
                        .accessibilityLabel("プライバシーポリシー")
                    Link("ヘルプ", destination: URL(string: "https://gakuse.ai/help")!)
                        .accessibilityIdentifier("help")
                        .accessibilityLabel("ヘルプ")

                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityIdentifier("versionInfo")
                    .accessibilityLabel("バージョン情報 \(appVersion)")
                }

                // Logout Section
                Section {
                    Button("ログアウト", role: .destructive) {
                        showingLogoutConfirmation = true
                    }
                    .accessibilityIdentifier("logoutButton")
                    .accessibilityLabel("ログアウト")
                    .accessibilityHint("アカウントからログアウトします")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("設定画面")
            .navigationTitle("設定")
            .drawingGroup() // パフォーマンス最適化: レイヤー合成を1回にまとめる
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
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingThemePicker) {
                ThemePickerView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAvatarPicker) {
                AvatarPickerView(viewModel: viewModel)
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

    // MARK: - Helper Methods

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var languageDisplayName: String {
        viewModel.userProfile?.settings.language.displayName ?? "日本語"
    }

    private func deleteAllData() {
        isDeletingData = true
        Task {
            await viewModel.deleteAllData()
            isDeletingData = false
        }
    }
}

// MARK: - Setting Row

struct SettingRow: View {
    let icon: String
    let title: String
    var showChevron: Bool = false
    @State private var isPressed = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .frame(width: 24)
            Text(title)
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Notification Settings View

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("通知を有効にする", isOn: Binding(
                        get: { viewModel.userProfile?.settings.notificationsEnabled ?? true },
                        set: { newValue in
                            Task {
                                var settings = viewModel.userProfile?.settings ?? UserSettings()
                                settings.notificationsEnabled = newValue
                                await viewModel.updateSettings(settings)
                            }
                        }
                    ))
                }

                if viewModel.userProfile?.settings.notificationsEnabled == true {
                    Section("通知時間") {
                        DatePicker("通知時間", selection: Binding(
                            get: {
                                guard let time = viewModel.userProfile?.settings.notificationTime else {
                                    return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
                                }
                                return Calendar.current.date(bySettingHour: time.hour ?? 9, minute: time.minute ?? 0, second: 0, of: Date()) ?? Date()
                            },
                            set: { newDate in
                                Task {
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                    await viewModel.updateNotificationTime(components)
                                }
                            }
                        ), displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                    }
                }
            }
            .navigationTitle("通知")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Appearance Settings View

struct AppearanceSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("テーマ") {
                    Picker("テーマ", selection: Binding(
                        get: { viewModel.userProfile?.settings.theme ?? .system },
                        set: { newTheme in
                            Task {
                                await viewModel.updateTheme(newTheme)
                            }
                        }
                    )) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("プレビュー") {
                    HStack {
                        Text("現在のテーマ")
                        Spacer()
                        Text(currentThemeName)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("外観")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }

    private var currentThemeName: String {
        viewModel.userProfile?.settings.theme.displayName ?? "システム"
    }
}

// MARK: - Language Settings View

struct LanguageSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("言語") {
                    Picker("言語", selection: Binding(
                        get: { viewModel.userProfile?.settings.language ?? .japanese },
                        set: { newLanguage in
                            Task {
                                await viewModel.updateLanguage(newLanguage)
                            }
                        }
                    )) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section {
                    Text("言語設定を変更すると、アプリが再起動されます。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("言語")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Avatar Picker View

struct AvatarPickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @Namespace private var animation

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(Array(AvatarIcon.allCases.enumerated()), id: \.element) { index, icon in
                        AvatarButton(
                            icon: icon,
                            isSelected: viewModel.userProfile?.avatarIcon == icon.rawValue,
                            namespace: animation
                        ) {
                            await selectAvatar(icon)
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                    }
                }
                .padding()
            }
            .navigationTitle("アバター選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .presentationDragIndicator(.visible)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.userProfile?.avatarIcon)
    }

    private func selectAvatar(_ icon: AvatarIcon) async {
        await viewModel.updateProfile(name: viewModel.userProfile?.name ?? "ユーザー", avatarIcon: icon.rawValue)
        dismiss()
    }
}

// MARK: - Avatar Button Component

struct AvatarButton: View {
    let icon: AvatarIcon
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () async -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            ZStack {
                // グラデーション背景
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: shadowColor.opacity(0.3),
                        radius: isPressed ? 4 : (isSelected ? 8 : 4),
                        x: 0,
                        y: isPressed ? 2 : (isSelected ? 4 : 2)
                    )

                // アイコン
                Image(systemName: icon.rawValue)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                // 選択時のチェックマーク
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(checkmarkColor)
                            .font(.title3)
                    }
                    .offset(x: 28, y: -28)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(AvatarButtonStyle(isPressed: $isPressed))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }

    private var gradientColors: [Color] {
        if isSelected {
            return [Color.pink, Color.purple]
        } else {
            return [Color.pink.opacity(0.7), Color.purple.opacity(0.7)]
        }
    }

    private var shadowColor: Color {
        Color.primary.opacity(0.2)
    }

    private var checkmarkColor: Color {
        Color.pink
    }
}

// MARK: - Avatar Button Style

struct AvatarButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : (isPressed ? 0.88 : 1.0))
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                isPressed = newValue
            }
    }
}

enum AvatarIcon: String, CaseIterable {
    case person = "person.fill"
    case star = "star.fill"
    case heart = "heart.fill"
    case bolt = "bolt.fill"
    case flame = "flame.fill"
    case cloud = "cloud.fill"
    case sun = "sun.max.fill"
    case moon = "moon.fill"
    case sparkle = "sparkles"
    case trophy = "trophy.fill"
    case rocket = "rocket.fill"

    var displayName: String {
        switch self {
        case .person: return "デフォルト"
        case .star: return "スター"
        case .heart: return "ハート"
        case .bolt: return "雷"
        case .flame: return "炎"
        case .cloud: return "クラウド"
        case .sun: return "太陽"
        case .moon: return "月"
        case .sparkle: return "キラキラ"
        case .trophy: return "トロフィー"
        case .rocket: return "ロケット"
        }
    }
}

// MARK: - Data Export View

struct DataExportView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var isExporting = false
    @State private var exportedURL: URL?
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section("エクスポート形式") {
                    Button {
                        exportToCSV()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.pink)
                            VStack(alignment: .leading) {
                                Text("CSV形式")
                                    .font(.headline)
                                Text("スプレッドシートで開ける形式")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Button {
                        exportToJSON()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.pink)
                            VStack(alignment: .leading) {
                                Text("JSON形式")
                                    .font(.headline)
                                Text("データ形式でエクスポート")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section {
                    Text("学習ログ、プロファイル、チャット履歴をエクスポートします。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("データエクスポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func exportToCSV() {
        isExporting = true
        defer { isExporting = false }

        Task {
            // LearningLogViewModelを作成してCSVエクスポートを実行
            let logViewModel = LearningLogViewModel()
            await logViewModel.loadLogs()

            if let url = logViewModel.exportToCSV() {
                exportedURL = url
                showingShareSheet = true
            } else if let error = logViewModel.errorMessage {
                print("CSVエクスポートエラー: \(error)")
            }
        }
    }

    private func exportToJSON() {
        isExporting = true
        defer { isExporting = false }

        Task {
            do {
                let url = try await viewModel.exportAllData()
                exportedURL = url
                showingShareSheet = true
            } catch {
                // Handle error
                print("エクスポートエラー: \(error)")
            }
        }
    }
}

// MARK: - Helper Views

struct ProfileButtonContent: View {
    let profile: UserProfile?
    @State private var isPressed = false

    var body: some View {
        HStack {
            AvatarView(avatarIcon: profile?.avatarIcon, name: profile?.name)

            ProfileInfoView(profile: profile)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .foregroundColor(.primary)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct AvatarView: View {
    let avatarIcon: String?
    let name: String?

    var body: some View {
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
                if let icon = avatarIcon {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(.white)
                } else {
                    Text(initialLetter)
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
            }
    }

    private var initialLetter: String {
        name?.first?.uppercased() ?? "U"
    }
}

struct ProfileInfoView: View {
    let profile: UserProfile?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(displayName)
                .font(.headline)

            Text(displayEmail)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var displayName: String {
        profile?.name ?? "ユーザー"
    }

    private var displayEmail: String {
        if let email = profile?.email {
            return email
        } else {
            return "メールアドレス未設定"
        }
    }
}

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

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ProfileView()
}
