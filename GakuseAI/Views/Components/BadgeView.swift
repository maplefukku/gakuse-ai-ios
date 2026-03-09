import SwiftUI

/// バッジ表示用コンポーネント
/// 通知数、ステータス表示に使用
struct BadgeView: View {
    let count: Int
    let maxCount: Int

    init(count: Int, maxCount: Int = 99) {
        self.count = count
        self.maxCount = maxCount
    }

    var body: some View {
        Text(displayCount)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Circle()
                    .fill(count > 0 ? .red : .gray)
            )
            .drawingGroup()
    }

    private var displayCount: String {
        if count <= 0 {
            return ""
        } else if count > maxCount {
            return "\(maxCount)+"
        } else {
            return "\(count)"
        }
    }
}

/// ステータスバッジコンポーネント
struct StatusBadge: View {
    enum Status {
        case success
        case warning
        case error
        case info
        case pending
    }

    let status: Status
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(statusColor.opacity(0.1))
        )
        .drawingGroup()
    }

    private var statusColor: Color {
        switch status {
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        case .info:
            return .blue
        case .pending:
            return .gray
        }
    }
}

/// タグバッジコンポーネント
struct TagBadge: View {
    let text: String
    let color: Color
    let isRemovable: Bool
    let onRemove: (() -> Void)?

    init(text: String, color: Color = .pink, isRemovable: Bool = false, onRemove: (() -> Void)? = nil) {
        self.text = text
        self.color = color
        self.isRemovable = isRemovable
        self.onRemove = onRemove
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .foregroundColor(.white)

            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color)
        )
        .drawingGroup()
    }
}

// MARK: - Preview

#Preview("Badge View") {
    VStack(spacing: 16) {
        BadgeView(count: 0)
        BadgeView(count: 1)
        BadgeView(count: 5)
        BadgeView(count: 99)
        BadgeView(count: 100)
    }
    .padding()
}

#Preview("Status Badge") {
    VStack(spacing: 16) {
        StatusBadge(status: .success, text: "成功")
        StatusBadge(status: .warning, text: "警告")
        StatusBadge(status: .error, text: "エラー")
        StatusBadge(status: .info, text: "情報")
        StatusBadge(status: .pending, text: "保留中")
    }
    .padding()
}

#Preview("Tag Badge") {
    VStack(spacing: 16) {
        TagBadge(text: "Swift", color: .orange)
        TagBadge(text: "UI/UX", color: .purple)
        TagBadge(text: "学習", color: .blue, isRemovable: true, onRemove: {})
    }
    .padding()
}
