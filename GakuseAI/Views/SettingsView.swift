import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("appLanguage") private var appLanguage = "ja"
    @AppStorage("appTheme") private var appTheme = "system"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = true
    @AppStorage("weeklySummaryEnabled") private var weeklySummaryEnabled = true
    @State private var isPressed = false

    private let languages = [
        ("ja", "日本語"),
        ("en", "English"),
        ("zh", "中文")
    ]

    private let themes = [
        ("system", "システム"),
        ("light", "ライト"),
        ("dark", "ダーク")
    ]

    var body: some View {
        NavigationView {
            List {
                // 言語設定セクション
                Section {
                    ForEach(languages, id: \.0) { code, name in
                        LanguageRow(
                            code: code,
                            name: name,
                            isSelected: appLanguage == code,
                            onSelect: {
                                withAnimation(.spring(response: 0.3)) {
                                    appLanguage = code
                                }
                            }
                        )
                    }
                } header: {
                    Text("言語設定")
                }

                // テーマ設定セクション
                Section {
                    ForEach(themes, id: \.0) { code, name in
                        ThemeRow(
                            code: code,
                            name: name,
                            isSelected: appTheme == code,
                            onSelect: {
                                withAnimation(.spring(response: 0.3)) {
                                    appTheme = code
                                }
                            }
                        )
                    }
                } header: {
                    Text("テーマ設定")
                }

                // 通知設定セクション
                Section {
                    ToggleRow(
                        icon: "bell.fill",
                        title: "通知を有効にする",
                        isOn: $notificationsEnabled
                    )

                    if notificationsEnabled {
                        ToggleRow(
                            icon: "clock.fill",
                            title: "毎日のリマインダー",
                            isOn: $dailyReminderEnabled
                        )

                        ToggleRow(
                            icon: "calendar.badge.clock",
                            title: "週間サマリー",
                            isOn: $weeklySummaryEnabled
                        )
                    }
                } header: {
                    Text("通知設定")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                    .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                        withAnimation {
                            isPressed = pressing
                        }
                    }, perform: {})
                }
            }
        }
        .accessibilityIdentifier("settingsView")
        .drawingGroup() // パフォーマンス最適化: レイヤー合成を1回にまとめる
    }
}

// MARK: - Language Row

struct LanguageRow: View {
    let code: String
    let name: String
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(name)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.pink)
                }
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityIdentifier("languageRow_\(code)")
    }
}

// MARK: - Theme Row

struct ThemeRow: View {
    let code: String
    let name: String
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(name)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.pink)
                }
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityIdentifier("themeRow_\(code)")
    }
}

// MARK: - Toggle Row

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    @State private var isPressed = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .frame(width: 24)

            Text(title)
                .foregroundColor(.primary)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.pink)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                    withAnimation {
                        isPressed = pressing
                    }
                }, perform: {})
        }
        .accessibilityIdentifier("toggleRow_\(title)")
    }
}
