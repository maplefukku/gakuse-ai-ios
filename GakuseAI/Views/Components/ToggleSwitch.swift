import SwiftUI

// MARK: - Toggle Switch Component

struct ToggleSwitch: View {
    @Binding var isOn: Bool
    let label: String?
    let icon: String?
    let iconColor: Color
    let onToggle: ((Bool) -> Void)?
    let style: ToggleStyle
    @State private var isPressed = false

    enum ToggleStyle {
        case standard
        case compact
        case colorful
    }

    init(
        isOn: Binding<Bool>,
        label: String? = nil,
        icon: String? = nil,
        iconColor: Color = .pink,
        onToggle: ((Bool) -> Void)? = nil,
        style: ToggleStyle = .standard
    ) {
        self._isOn = isOn
        self.label = label
        self.icon = icon
        self.iconColor = iconColor
        self.onToggle = onToggle
        self.style = style
    }

    var body: some View {
        Group {
            if let label = label {
                toggleRow
            } else {
                toggleButton
            }
        }
        .drawingGroup() // パフォーマンス最適化
    }

    private var toggleRow: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title3)
            }

            Text(label!)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            toggleButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
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
            toggle()
        }
    }

    private var toggleButton: some View {
        Button(action: toggle) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(isOn ? style.onColor : style.offColor)
                    .frame(
                        width: style.width,
                        height: style.height
                    )

                // Thumb
                Circle()
                    .fill(.white)
                    .frame(width: style.thumbSize, height: style.thumbSize)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .offset(x: isOn ? style.thumbOffset : -style.thumbOffset)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isOn)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label ?? "トグル")
        .accessibilityValue(isOn ? "オン" : "オフ")
        .accessibilityAddTraits(.isButton)
    }

    private func toggle() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            isOn.toggle()
        }
        onToggle?(isOn)
    }
}

// MARK: - Toggle Style Configuration

extension ToggleSwitch.ToggleStyle {
    var cornerRadius: CGFloat {
        switch self {
        case .standard, .compact: return height / 2
        case .colorful: return 12
        }
    }

    var width: CGFloat {
        switch self {
        case .standard: return 51
        case .compact: return 44
        case .colorful: return 60
        }
    }

    var height: CGFloat {
        switch self {
        case .standard: return 31
        case .compact: return 26
        case .colorful: return 36
        }
    }

    var thumbSize: CGFloat {
        switch self {
        case .standard: return 27
        case .compact: return 22
        case .colorful: return 28
        }
    }

    var thumbOffset: CGFloat {
        (width - thumbSize) / 2 - 2
    }

    var onColor: Color {
        switch self {
        case .standard: return Color(UIColor.systemGreen)
        case .compact: return Color(UIColor.systemGreen)
        case .colorful: return .pink
        }
    }

    var offColor: Color {
        switch self {
        case .standard: return Color(UIColor.systemGray4)
        case .compact: return Color(UIColor.systemGray4)
        case .colorful: return .gray.opacity(0.3)
        }
    }
}

// MARK: - Compact Toggle (No Label)

struct CompactToggle: View {
    @Binding var isOn: Bool
    let color: Color
    let onToggle: ((Bool) -> Void)?
    @State private var isPressed = false

    init(
        isOn: Binding<Bool>,
        color: Color = .pink,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self._isOn = isOn
        self.color = color
        self.onToggle = onToggle
    }

    var body: some View {
        Button(action: toggle) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(isOn ? color : Color(UIColor.systemGray4))
                    .frame(width: 44, height: height)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isOn)

                // Thumb
                Circle()
                    .fill(.white)
                    .frame(width: 22, height: 22)
                    .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                    .offset(x: isOn ? thumbOffset : -thumbOffset)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isOn)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .drawingGroup() // パフォーマンス最適化
        .accessibilityElement(children: .ignore)
        .accessibilityValue(isOn ? "オン" : "オフ")
        .accessibilityAddTraits(.isButton)
    }

    private var height: CGFloat {
        26
    }

    private var thumbOffset: CGFloat {
        8
    }

    private func toggle() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            isOn.toggle()
        }
        onToggle?(isOn)
    }
}

// MARK: - Preview

#Preview("Toggle Switch - Standard") {
    VStack(spacing: 16) {
        ToggleSwitch(
            isOn: .constant(true),
            label: "通知",
            icon: "bell.fill",
            iconColor: .blue
        )

        ToggleSwitch(
            isOn: .constant(false),
            label: "ダークモード",
            icon: "moon.fill",
            iconColor: .purple
        )

        ToggleSwitch(
            isOn: .constant(true),
            label: "毎日のリマインダー",
            icon: "clock.fill",
            iconColor: .green
        )
    }
    .padding()
}

#Preview("Toggle Switch - Compact") {
    VStack(spacing: 16) {
        ToggleSwitch(
            isOn: .constant(true),
            label: "通知",
            style: .compact
        )

        ToggleSwitch(
            isOn: .constant(false),
            label: "ダークモード",
            style: .compact
        )
    }
    .padding()
}

#Preview("Toggle Switch - Colorful") {
    VStack(spacing: 16) {
        ToggleSwitch(
            isOn: .constant(true),
            label: "通知",
            style: .colorful,
            iconColor: .pink
        )

        ToggleSwitch(
            isOn: .constant(false),
            label: "ダークモード",
            style: .colorful,
            iconColor: .purple
        )
    }
    .padding()
}

#Preview("Toggle Switch - No Label") {
    VStack(spacing: 16) {
        HStack {
            Text("通知")
                .font(.subheadline)
            Spacer()
            ToggleSwitch(isOn: .constant(true))
        }

        HStack {
            Text("ダークモード")
                .font(.subheadline)
            Spacer()
            ToggleSwitch(isOn: .constant(false))
        }
    }
    .padding()
}

#Preview("Compact Toggle") {
    VStack(spacing: 16) {
        HStack {
            Text("通知")
                .font(.subheadline)
            Spacer()
            CompactToggle(isOn: .constant(true))
        }

        HStack {
            Text("ダークモード")
                .font(.subheadline)
            Spacer()
            CompactToggle(isOn: .constant(false))
        }

        HStack {
            Text("毎日のリマインダー")
                .font(.subheadline)
            Spacer()
            CompactToggle(isOn: .constant(true), color: .green)
        }
    }
    .padding()
}
