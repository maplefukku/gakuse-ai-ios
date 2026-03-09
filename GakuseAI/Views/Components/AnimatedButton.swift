import SwiftUI

/// アニメーション付きボタンのベースコンポーネント
struct AnimatedButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    let isEnabled: Bool
    let isSecondary: Bool

    @State private var isPressed = false

    enum ButtonStyle {
        case primary
        case secondary
        case danger
        case success
    }

    init(
        title: String,
        icon: String? = nil,
        action: @escaping () -> Void,
        style: ButtonStyle = .primary,
        isEnabled: Bool = true,
        isSecondary: Bool = false
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.style = style
        self.isEnabled = isEnabled
        self.isSecondary = isSecondary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }

                Text(title)
            }
            .font(.headline)
            .foregroundColor(foregroundColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: shadowColor, radius: isPressed ? 2 : 4, x: 0, y: isPressed ? 1 : 2)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
        .drawingGroup()
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
    }

    private var foregroundColor: Color {
        isEnabled ? (style == .secondary || isSecondary ? .primary : .white) : .gray
    }

    private var backgroundColor: Color {
        if !isEnabled {
            return Color.gray.opacity(0.1)
        }

        switch style {
        case .primary:
            return isSecondary ? Color.clear : Color.pink
        case .secondary:
            return Color.clear
        case .danger:
            return isSecondary ? Color.clear : Color.red
        case .success:
            return isSecondary ? Color.clear : Color.green
        }
    }

    private var borderColor: Color {
        if isSecondary || style == .secondary {
            return isEnabled ? (style == .danger ? Color.red : style == .success ? Color.green : Color.pink) : Color.gray
        }
        return Color.clear
    }

    private var borderWidth: CGFloat {
        isSecondary || style == .secondary ? 1.5 : 0
    }

    private var shadowColor: Color {
        if !isEnabled {
            return Color.clear
        }

        switch style {
        case .primary:
            return Color.pink.opacity(0.3)
        case .secondary:
            return Color.clear
        case .danger:
            return Color.red.opacity(0.3)
        case .success:
            return Color.green.opacity(0.3)
        }
    }
}

/// フローティングアクションボタン（FAB）
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    let size: CGFloat

    @State private var isPressed = false

    enum Size {
        case small
        case medium
        case large

        var value: CGFloat {
            switch self {
            case .small: return 44
            case .medium: return 56
            case .large: return 64
            }
        }
    }

    init(icon: String, action: @escaping () -> Void, size: Size = .medium) {
        self.icon = icon
        self.action = action
        self.size = size.value
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .pink.opacity(0.4), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 2 : 4)
                )
                .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .drawingGroup()
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

/// アイコンボタンのコンポーネント
struct IconButton: View {
    let icon: String
    let action: () -> Void
    let size: CGFloat
    let color: Color

    @State private var isPressed = false

    enum Size {
        case small
        case medium
        case large

        var value: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            }
        }
    }

    init(icon: String, action: @escaping () -> Void, size: Size = .medium, color: Color = .pink) {
        self.icon = icon
        self.action = action
        self.size = size.value
        self.color = color
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.5))
                .foregroundColor(.primary)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .drawingGroup()
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Preview

#Preview("Animated Button") {
    VStack(spacing: 16) {
        AnimatedButton(title: "保存", action: {})
        AnimatedButton(title: "キャンセル", style: .secondary, action: {})
        AnimatedButton(title: "削除", style: .danger, action: {})
        AnimatedButton(title: "完了", style: .success, action: {})
        AnimatedButton(title: "無効", isEnabled: false, action: {})
    }
    .padding()
}

#Preview("Animated Button with Icon") {
    VStack(spacing: 16) {
        AnimatedButton(title: "保存", icon: "square.and.arrow.down", action: {})
        AnimatedButton(title: "編集", icon: "pencil", style: .secondary, action: {})
        AnimatedButton(title: "削除", icon: "trash", style: .danger, action: {})
    }
    .padding()
}

#Preview("Floating Action Button") {
    VStack(spacing: 32) {
        FloatingActionButton(icon: "plus", size: .small, action: {})
        FloatingActionButton(icon: "plus", size: .medium, action: {})
        FloatingActionButton(icon: "plus", size: .large, action: {})
    }
    .padding()
}

#Preview("Icon Button") {
    HStack(spacing: 16) {
        IconButton(icon: "heart", size: .small, color: .red, action: {})
        IconButton(icon: "heart", size: .medium, color: .pink, action: {})
        IconButton(icon: "heart", size: .large, color: .purple, action: {})
    }
    .padding()
}
