import SwiftUI

// MARK: - Segmented Control Component

struct SegmentedControl: View {
    @Binding var selectedIndex: Int
    let options: [String]
    let icons: [String]?
    let style: SegmentedStyle
    let onSelectionChange: ((Int) -> Void)?
    @State private var isPressed = false

    enum SegmentedStyle {
        case standard
        case pill
        case minimal
        case underline
    }

    init(
        selectedIndex: Binding<Int>,
        options: [String],
        icons: [String]? = nil,
        style: SegmentedStyle = .standard,
        onSelectionChange: ((Int) -> Void)? = nil
    ) {
        self._selectedIndex = selectedIndex
        self.options = options
        self.icons = icons
        self.style = style
        self.onSelectionChange = onSelectionChange
    }

    var body: some View {
        Group {
            switch style {
            case .standard:
                standardStyle
            case .pill:
                pillStyle
            case .minimal:
                minimalStyle
            case .underline:
                underlineStyle
            }
        }
        .drawingGroup() // パフォーマンス最適化
    }

    private var standardStyle: some View {
        HStack(spacing: 0) {
            ForEach(0..<options.count, id: \.self) { index in
                segmentButton(at: index)
                    .background(
                        Rectangle()
                            .fill(selectedIndex == index ? style.selectedColor : Color.clear)
                    )
                    .overlay(
                        Rectangle()
                            .fill(style.borderColor)
                            .frame(width: 1)
                            .opacity(index < options.count - 1 ? 1 : 0)
                    )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(style.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .stroke(style.borderColor, lineWidth: style.borderWidth)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: selectedIndex)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("セグメントコントロール")
        .accessibilityValue(options[selectedIndex])
    }

    private var pillStyle: some View {
        HStack(spacing: 4) {
            ForEach(0..<options.count, id: \.self) { index in
                segmentButton(at: index)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(selectedIndex == index ? style.selectedColor : Color.clear)
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(style.backgroundColor)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("セグメントコントロール")
        .accessibilityValue(options[selectedIndex])
    }

    private var minimalStyle: some View {
        HStack(spacing: 2) {
            ForEach(0..<options.count, id: \.self) { index in
                segmentButton(at: index)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Rectangle()
                            .fill(selectedIndex == index ? style.selectedColor : Color.clear)
                    )
                    .cornerRadius(8)
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: selectedIndex)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("セグメントコントロール")
        .accessibilityValue(options[selectedIndex])
    }

    private var underlineStyle: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ForEach(0..<options.count, id: \.self) { index in
                    segmentButton(at: index)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Underline indicator
            GeometryReader { geometry in
                let segmentWidth = geometry.size.width / CGFloat(options.count)
                Rectangle()
                    .fill(style.selectedColor)
                    .frame(width: segmentWidth - 32, height: 3)
                    .offset(x: CGFloat(selectedIndex) * segmentWidth + 16)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
            }
            .frame(height: 3)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("セグメントコントロール")
        .accessibilityValue(options[selectedIndex])
    }

    @ViewBuilder
    private func segmentButton(at index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedIndex = index
            }
            onSelectionChange?(index)
        }) {
            HStack(spacing: 6) {
                if let icons = icons, index < icons.count, !icons[index].isEmpty {
                    Image(systemName: icons[index])
                        .font(style.iconFont)
                }

                Text(options[index])
                    .font(style.textFont)
                    .fontWeight(style.textWeight)
                    .foregroundColor(selectedIndex == index ? style.selectedTextColor : style.textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, style.horizontalPadding)
            .padding(.vertical, style.verticalPadding)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(options[index])
        .accessibilityAddTraits(selectedIndex == index ? [.isSelected] : [])
    }
}

// MARK: - Segmented Style Configuration

extension SegmentedControl.SegmentedStyle {
    var backgroundColor: Color {
        switch self {
        case .standard: return Color(UIColor.tertiarySystemBackground)
        case .pill: return Color(UIColor.secondarySystemBackground)
        case .minimal: return Color(UIColor.secondarySystemBackground)
        case .underline: return .clear
        }
    }

    var borderColor: Color {
        switch self {
        case .standard: return Color(UIColor.separator)
        case .pill, .minimal, .underline: return .clear
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .standard: return 1
        case .pill, .minimal, .underline: return 0
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .standard: return 8
        case .pill, .minimal, .underline: return 0
        }
    }

    var selectedColor: Color {
        switch self {
        case .standard: return .pink
        case .pill: return .pink
        case .minimal: return .pink.opacity(0.15)
        case .underline: return .pink
        }
    }

    var selectedTextColor: Color {
        switch self {
        case .standard, .pill, .underline: return .white
        case .minimal: return .pink
        }
    }

    var textColor: Color {
        switch self {
        case .standard, .pill: return .secondary
        case .minimal, .underline: return .primary
        }
    }

    var textFont: Font {
        switch self {
        case .standard: return .subheadline
        case .pill: return .subheadline
        case .minimal: return .caption
        case .underline: return .subheadline
        }
    }

    var fontWeight: Font.Weight {
        switch self {
        case .standard: return .medium
        case .pill: return .medium
        case .minimal: return .medium
        case .underline: return .semibold
        }
    }

    var iconFont: Font {
        switch self {
        case .standard: return .caption
        case .pill: return .caption
        case .minimal: return .caption2
        case .underline: return .caption
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .standard: return 12
        case .pill: return 8
        case .minimal: return 10
        case .underline: return 8
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .standard: return 10
        case .pill: return 6
        case .minimal: return 6
        case .underline: return 8
        }
    }
}

// MARK: - Icon Segmented Control

struct IconSegmentedControl: View {
    @Binding var selectedIndex: Int
    let icons: [String]
    let tooltips: [String]?
    let style: SegmentedControl.SegmentedStyle
    let onSelectionChange: ((Int) -> Void)?
    @State private var isPressed = false

    init(
        selectedIndex: Binding<Int>,
        icons: [String],
        tooltips: [String]? = nil,
        style: SegmentedControl.SegmentedStyle = .pill,
        onSelectionChange: ((Int) -> Void)? = nil
    ) {
        self._selectedIndex = selectedIndex
        self.icons = icons
        self.tooltips = tooltips
        self.style = style
        self.onSelectionChange = onSelectionChange
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<icons.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedIndex = index
                    }
                    onSelectionChange?(index)
                }) {
                    Image(systemName: icons[index])
                        .font(.title3)
                        .foregroundColor(selectedIndex == index ? .white : .secondary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(selectedIndex == index ? .pink : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(tooltips?[index] ?? icons[index])
                .accessibilityAddTraits(selectedIndex == index ? [.isSelected] : [])
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: selectedIndex)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .drawingGroup() // パフォーマンス最適化
    }
}

// MARK: - Preview

#Preview("Segmented Control - Standard") {
    VStack(spacing: 24) {
        SegmentedControl(
            selectedIndex: .constant(0),
            options: ["学習", "ポートフォリオ", "統計"]
        )

        SegmentedControl(
            selectedIndex: .constant(1),
            options: ["学習", "ポートフォリオ", "統計"]
        )

        SegmentedControl(
            selectedIndex: .constant(2),
            options: ["学習", "ポートフォリオ", "統計", "設定"]
        )
    }
    .padding()
}

#Preview("Segmented Control - Pill") {
    VStack(spacing: 24) {
        SegmentedControl(
            selectedIndex: .constant(0),
            options: ["学習", "ポートフォリオ", "統計"],
            style: .pill
        )

        SegmentedControl(
            selectedIndex: .constant(1),
            options: ["学習", "ポートフォリオ", "統計"],
            style: .pill
        )
    }
    .padding()
}

#Preview("Segmented Control - Minimal") {
    VStack(spacing: 24) {
        SegmentedControl(
            selectedIndex: .constant(0),
            options: ["学習", "ポートフォリオ", "統計"],
            style: .minimal
        )

        SegmentedControl(
            selectedIndex: .constant(1),
            options: ["今日", "今週", "今月"],
            style: .minimal
        )
    }
    .padding()
}

#Preview("Segmented Control - Underline") {
    VStack(spacing: 24) {
        SegmentedControl(
            selectedIndex: .constant(0),
            options: ["学習", "ポートフォリオ", "統計"],
            style: .underline
        )

        SegmentedControl(
            selectedIndex: .constant(1),
            options: ["学習", "ポートフォリオ", "統計"],
            style: .underline
        )
    }
    .padding()
}

#Preview("Segmented Control - With Icons") {
    VStack(spacing: 24) {
        SegmentedControl(
            selectedIndex: .constant(0),
            options: ["学習", "ポートフォリオ", "統計"],
            icons: ["book.fill", "folder.fill", "chart.bar.fill"]
        )

        SegmentedControl(
            selectedIndex: .constant(1),
            options: ["通知", "設定", "プロフィール"],
            icons: ["bell.fill", "gearshape.fill", "person.fill"]
        )

        SegmentedControl(
            selectedIndex: .constant(2),
            options: ["今日", "今週", "今月", "全期間"],
            icons: ["calendar", "calendar.badge.clock", "calendar.badge.plus", "calendar.dayperiod.left"],
            style: .pill
        )
    }
    .padding()
}

#Preview("Icon Segmented Control") {
    VStack(spacing: 24) {
        IconSegmentedControl(
            selectedIndex: .constant(0),
            icons: ["list.bullet", "square.grid.2x2", "chart.bar", "gearshape"]
        )

        IconSegmentedControl(
            selectedIndex: .constant(1),
            icons: ["list.bullet", "square.grid.2x2", "chart.bar", "gearshape"]
        )

        IconSegmentedControl(
            selectedIndex: .constant(2),
            icons: ["list.bullet", "square.grid.2x2", "chart.bar", "gearshape"]
        )
    }
    .padding()
}

#Preview("Segmented Control - Interactive") {
    struct InteractivePreview: View {
        @State private var selectedIndex = 0

        var body: some View {
            VStack(spacing: 24) {
                SegmentedControl(
                    selectedIndex: $selectedIndex,
                    options: ["学習", "ポートフォリオ", "統計"],
                    onSelectionChange: { index in
                        print("Selected: \(index)")
                    }
                )

                SegmentedControl(
                    selectedIndex: $selectedIndex,
                    options: ["学習", "ポートフォリオ", "統計"],
                    style: .pill
                )

                Text("選択中: \(selectedIndex)")
                    .font(.headline)
                    .foregroundColor(.pink)
            }
            .padding()
        }
    }

    return InteractivePreview()
}

#Preview("Segmented Control - Edge Cases") {
    VStack(spacing: 24) {
        SegmentedControl(
            selectedIndex: .constant(0),
            options: ["1つの項目"]
        )

        SegmentedControl(
            selectedIndex: .constant(0),
            options: ["とても長いテキストの項目", "短い", "中くらいの長さ"]
        )

        SegmentedControl(
            selectedIndex: .constant(0),
            options: ["📚", "📁", "📊", "⚙️", "👤", "🔔"],
            style: .minimal
        )
    }
    .padding()
}

#Preview("Segmented Control - In Context") {
    struct ContextPreview: View {
        @State private var selectedIndex = 0
        @State private var period = 0

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("統計情報")
                    .font(.title2)
                    .fontWeight(.bold)

                SegmentedControl(
                    selectedIndex: $period,
                    options: ["今日", "今週", "今月"],
                    icons: ["calendar", "calendar.badge.clock", "calendar.badge.plus"],
                    style: .pill
                )

                SegmentedControl(
                    selectedIndex: $selectedIndex,
                    options: ["学習時間", "完了タスク", "継続日数"]
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("詳細情報")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("選択: \(period) / \(selectedIndex)")
                        .font(.caption)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
    }

    return ContextPreview()
}
