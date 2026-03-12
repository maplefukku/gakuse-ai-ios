import SwiftUI

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
