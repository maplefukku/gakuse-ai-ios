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

#Preview {
    ProfileView()
}
