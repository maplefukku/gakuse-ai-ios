import SwiftUI

// MARK: - Card View Component

struct CardView<Content: View>: View {
    let content: Content
    let title: String?
    let icon: String?
    let iconColor: Color
    let onTap: (() -> Void)?
    let style: CardStyle
    @State private var isPressed = false
    @State private var isHovered = false

    enum CardStyle {
        case standard
        case elevated
        case outlined
        case minimal
    }

    init(
        title: String? = nil,
        icon: String? = nil,
        iconColor: Color = .pink,
        onTap: (() -> Void)? = nil,
        style: CardStyle = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.onTap = onTap
        self.style = style
        self.content = content()
    }

    var body: some View {
        Group {
            if onTap != nil {
                interactiveCard
            } else {
                staticCard
            }
        }
        .drawingGroup() // パフォーマンス最適化
    }

    private var interactiveCard: some View {
        Button(action: {
            onTap?()
        }) {
            cardContent
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : (isHovered ? 1.02 : 1.0))
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        #if os(iOS)
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
        #endif
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title ?? "カード")
        .accessibilityAddTraits(.isButton)
    }

    private var staticCard: some View {
        cardContent
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title ?? "カード")
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(style.padding)
        .background(style.background)
        .cornerRadius(style.cornerRadius)
        .shadow(color: style.shadowColor, radius: style.shadowRadius, x: 0, y: style.shadowOffset)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(style.borderColor, lineWidth: style.borderWidth)
        )
    }

    private var header: some View {
        Group {
            if let title = title {
                HStack(spacing: 8) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundColor(iconColor)
                            .font(.title3)
                    }

                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Card Style Configuration

extension CardView.CardStyle {
    var padding: EdgeInsets {
        switch self {
        case .standard: return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        case .elevated: return EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        case .outlined: return EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        case .minimal: return EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .standard: return 16
        case .elevated: return 20
        case .outlined: return 12
        case .minimal: return 8
        }
    }

    var background: Color {
        switch self {
        case .standard, .outlined, .minimal: return Color(UIColor.secondarySystemBackground)
        case .elevated: return Color(UIColor.tertiarySystemBackground)
        }
    }

    var borderColor: Color {
        switch self {
        case .outlined: return Color(UIColor.separator)
        default: return .clear
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .outlined: return 1
        default: return 0
        }
    }

    var shadowColor: Color {
        switch self {
        case .elevated: return .black.opacity(0.15)
        case .standard: return .black.opacity(0.08)
        case .outlined, .minimal: return .clear
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .elevated: return 8
        case .standard: return 4
        case .outlined, .minimal: return 0
        }
    }

    var shadowOffset: CGFloat {
        switch self {
        case .elevated: return 4
        case .standard: return 2
        case .outlined, .minimal: return 0
        }
    }
}

// MARK: - Compact Card (Minimal)

struct CompactCard<Content: View>: View {
    let content: Content
    let onTap: (() -> Void)?
    @State private var isPressed = false

    init(
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.onTap = onTap
        self.content = content()
    }

    var body: some View {
        Group {
            if onTap != nil {
                Button(action: {
                    onTap?()
                }) {
                    cardContent
                }
                .buttonStyle(.plain)
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                    withAnimation {
                        isPressed = pressing
                    }
                }, perform: {})
            } else {
                cardContent
            }
        }
        .drawingGroup() // パフォーマンス最適化
    }

    private var cardContent: some View {
        content
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(UIColor.separator.opacity(0.3)), lineWidth: 1)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("コンパクトカード")
            .accessibilityAddTraits(onTap != nil ? [.isButton] : [])
    }
}

// MARK: - Preview

#Preview("Card View - Standard") {
    VStack(spacing: 16) {
        CardView(title: "学習ログ", icon: "book.fill", iconColor: .blue) {
            Text("今日の学習内容を記録")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text("3時間")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                Spacer()
            }
        }

        CardView(title: "ポートフォリオ", icon: "folder.fill", iconColor: .purple) {
            Text("作成した作品の管理")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text("5件")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                Spacer()
            }
        }
    }
    .padding()
}

#Preview("Card View - Elevated") {
    VStack(spacing: 16) {
        CardView(
            title: "統計情報",
            icon: "chart.bar.fill",
            iconColor: .green,
            style: .elevated
        ) {
            HStack {
                VStack(alignment: .leading) {
                    Text("今週の学習時間")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("25時間")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title)
                    .foregroundColor(.green)
            }
        }
    }
    .padding()
}

#Preview("Card View - Outlined") {
    VStack(spacing: 16) {
        CardView(
            title: "通知設定",
            icon: "bell.fill",
            iconColor: .orange,
            style: .outlined
        ) {
            Text("プッシュ通知の設定")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text("有効")
                    .font(.caption)
                    .foregroundColor(.green)
                Spacer()
            }
        }
    }
    .padding()
}

#Preview("Card View - Minimal") {
    VStack(spacing: 16) {
        CardView(style: .minimal) {
            Text("最小限のカード")
                .font(.subheadline)
        }
    }
    .padding()
}

#Preview("Card View - Interactive") {
    VStack(spacing: 16) {
        CardView(
            title: "タップ可能",
            icon: "hand.tap.fill",
            iconColor: .pink,
            onTap: { print("Card tapped!") }
        ) {
            Text("このカードはタップ可能")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }

        CardView(
            title: "ボタンなし",
            icon: "hand.palm.fill",
            iconColor: .gray
        ) {
            Text("このカードはタップ不可")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    .padding()
}

#Preview("Compact Card") {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            CompactCard {
                Text("アイテム 1")
                    .font(.caption)
            }

            CompactCard {
                Text("アイテム 2")
                    .font(.caption)
            }

            CompactCard {
                Text("アイテム 3")
                    .font(.caption)
            }
        }

        HStack(spacing: 12) {
            CompactCard(onTap: { print("Compact card 1 tapped") }) {
                Text("タップ可能")
                    .font(.caption)
            }

            CompactCard(onTap: { print("Compact card 2 tapped") }) {
                Text("タップ可能")
                    .font(.caption)
            }
        }
    }
    .padding()
}

#Preview("Card View - Complex Content") {
    ScrollView {
        VStack(spacing: 16) {
            CardView(title: "プロジェクト", icon: "folder.fill", iconColor: .blue) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SwiftUIアプリ開発")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("iOS 17対応のモダンなアプリを開発中。MVVMアーキテクチャを採用し、テストカバレッジを向上させる。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)

                    HStack(spacing: 8) {
                        Label("進捗", systemImage: "chart.pie.fill")
                            .font(.caption2)
                        Label("テスト", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                        Label("リファクタ", systemImage: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
            }

            CardView(title: "統計", icon: "chart.bar.fill", iconColor: .green) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("今週")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("25時間")
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("今月")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("98時間")
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("累計")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("423時間")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .padding()
    }
}
