import SwiftUI

// MARK: - Notification Card Component

struct NotificationCard: View {
    let title: String
    let message: String
    let icon: String
    let iconColor: Color
    var timestamp: String?
    var isUnread: Bool = false
    var onTap: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    @State private var isPressed = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                if let timestamp = timestamp {
                    Text(timestamp)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Actions
            VStack(spacing: 8) {
                if isUnread {
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 8, height: 8)
                }

                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(isUnread ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isUnread ? Color.pink.opacity(0.3) : Color.clear,
                    lineWidth: 2
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
        .drawingGroup() // パフォーマンス最適化
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(message)
        .accessibilityAddTraits(isUnread ? [.isButton] : [])
    }
}

// MARK: - Notification Row (Compact)

struct NotificationRow: View {
    let title: String
    let message: String
    let icon: String
    let iconColor: Color
    var isUnread: Bool = false
    var onTap: (() -> Void)? = nil
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 24)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fontWeight(isUnread ? .semibold : .regular)

                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if isUnread {
                Circle()
                    .fill(Color.pink)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(isUnread ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground))
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
        .drawingGroup() // パフォーマンス最適化
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(message)
    }
}

// MARK: - Preview

#Preview("Notification Card - Unread") {
    VStack(spacing: 16) {
        NotificationCard(
            title: "毎日のリマインダー",
            message: "今日の学習ログを記録しましょう！",
            icon: "bell.fill",
            iconColor: .blue,
            timestamp: "5分前",
            isUnread: true,
            onTap: {
                print("Tapped")
            },
            onDismiss: {
                print("Dismissed")
            }
        )
    }
    .padding()
}

#Preview("Notification Card - Read") {
    VStack(spacing: 16) {
        NotificationCard(
            title: "週間サマリー",
            message: "今週は20時間の学習を達成しました！",
            icon: "chart.bar.fill",
            iconColor: .green,
            timestamp: "1時間前",
            isUnread: false
        )

        NotificationCard(
            title: "新しいスキル",
            message: "SwiftUIの学習を完了しました",
            icon: "star.fill",
            iconColor: .orange
        )
    }
    .padding()
}

#Preview("Notification Row") {
    VStack(spacing: 8) {
        NotificationRow(
            title: "毎日のリマインダー",
            message: "今日の学習ログを記録しましょう！",
            icon: "bell.fill",
            iconColor: .blue,
            isUnread: true
        )

        NotificationRow(
            title: "週間サマリー",
            message: "今週は20時間の学習を達成しました！",
            icon: "chart.bar.fill",
            iconColor: .green,
            isUnread: false
        )
    }
    .padding()
}
