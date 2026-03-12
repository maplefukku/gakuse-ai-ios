import SwiftUI

/// アイコンボタンの汎用コンポーネント
/// 各Viewで定義・使用されているローカルコンポーネントを統合・再利用
///
/// ## 使用例
/// ```swift
/// // 削除ボタン
/// IconButton(
///     icon: "trash",
///     iconColor: .red,
///     action: { /* 削除処理 */ }
/// )
///
/// // スキル追加ボタン
/// IconButton(
///     icon: "plus.circle.fill",
///     iconColor: .pink,
///     size: .large,
///     action: { /* 追加処理 */ }
/// )
///
/// // カスタムスタイル
/// IconButton(
///     icon: "pencil",
///     iconColor: .blue,
///     backgroundColor: .blue.opacity(0.2),
///     size: .medium,
///     action: { /* 編集処理 */ }
/// )
/// ```
struct IconButton: View {
    let icon: String
    let iconColor: Color
    var backgroundColor: Color? = nil
    var size: IconSize = .medium
    let action: () -> Void
    @State private var isPressed = false

    /// ボタンサイズの定義
    enum IconSize {
        case small   // 20x20
        case medium  // 24x24（デフォルト）
        case large   // 32x32

        var iconScale: CGFloat {
            switch self {
            case .small: return 0.8
            case .medium: return 1.0
            case .large: return 1.2
            }
        }

        var buttonPadding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // 背景色（指定されている場合）
                if let backgroundColor = backgroundColor {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: size.buttonPadding * 2 + iconSize, height: size.buttonPadding * 2 + iconSize)
                }

                // アイコン
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: iconSize))
            }
            .padding(size.buttonPadding)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityLabel(accessibilityLabel)
    }

    private var iconSize: CGFloat {
        switch size {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        }
    }

    private var accessibilityLabel: String {
        // アイコン名に基づいてアクセシビリティラベルを生成
        if icon.contains("trash") {
            return "削除"
        } else if icon.contains("plus") {
            return "追加"
        } else if icon.contains("pencil") {
            return "編集"
        } else {
            return "ボタン"
        }
    }
}

// MARK: - Predefined Icon Buttons

/// 削除ボタン（デフォルトスタイル）
struct DeleteButton: View {
    let action: () -> Void

    var body: some View {
        IconButton(
            icon: "trash",
            iconColor: .red,
            size: .medium,
            action: action
        )
    }
}

/// スキル追加ボタン（デフォルトスタイル）
struct SkillAddButton: View {
    let action: () -> Void

    var body: some View {
        IconButton(
            icon: "plus.circle.fill",
            iconColor: .pink,
            size: .medium,
            action: action
        )
    }
}

/// アイコンボタン（背景色付き）
struct IconButtonWithBackground: View {
    let icon: String
    let iconColor: Color
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        IconButton(
            icon: icon,
            iconColor: iconColor,
            backgroundColor: backgroundColor,
            size: .medium,
            action: action
        )
    }
}

// MARK: - Preview

#Preview("Delete Button") {
    DeleteButton(action: {})
        .padding()
}

#Preview("Skill Add Button") {
    SkillAddButton(action: {})
        .padding()
}

#Preview("Icon Button - Small") {
    IconButton(
        icon: "trash",
        iconColor: .red,
        size: .small,
        action: {}
    )
    .padding()
}

#Preview("Icon Button - Medium") {
    IconButton(
        icon: "pencil",
        iconColor: .blue,
        size: .medium,
        action: {}
    )
    .padding()
}

#Preview("Icon Button - Large") {
    IconButton(
        icon: "plus.circle.fill",
        iconColor: .pink,
        size: .large,
        action: {}
    )
    .padding()
}

#Preview("Icon Button - With Background") {
    IconButton(
        icon: "heart.fill",
        iconColor: .white,
        backgroundColor: .pink,
        size: .large,
        action: {}
    )
    .padding()
}

#Preview("Various Icon Buttons") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            DeleteButton(action: {})
            SkillAddButton(action: {})
            IconButton(icon: "pencil", iconColor: .blue, action: {})
        }

        HStack(spacing: 20) {
            IconButton(icon: "heart.fill", iconColor: .red, size: .small, action: {})
            IconButton(icon: "star.fill", iconColor: .yellow, size: .medium, action: {})
            IconButton(icon: "bolt.fill", iconColor: .blue, size: .large, action: {})
        }

        HStack(spacing: 20) {
            IconButton(icon: "trash", iconColor: .white, backgroundColor: .red, action: {})
            IconButton(icon: "pencil", iconColor: .white, backgroundColor: .blue, action: {})
            IconButton(icon: "plus.circle.fill", iconColor: .white, backgroundColor: .pink, action: {})
        }
    }
    .padding()
}
