//
//  AvatarGroup.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-09.
//

import SwiftUI

// MARK: - Avatar Group
struct AvatarGroup: View {
    let avatars: [AvatarGroupItem]
    var style: AvatarGroupStyle = .standard
    var size: CGFloat = 40
    var spacing: CGFloat = -10
    var maxVisible: Int = 5
    var overflowCount: Int?
    var onTap: ((Int) -> Void)? = nil
    var onOverflowTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(Array(avatars.prefix(maxVisible).enumerated()), id: \.element.id) { index, avatar in
                AvatarView(
                    image: avatar.image,
                    initials: avatar.initials,
                    color: avatar.color,
                    size: size,
                    style: style.avatarStyle
                )
                .overlay(
                    Circle()
                        .stroke(
                            Color(.systemBackground),
                            lineWidth: style.borderWidth
                        )
                )
                .scaleEffect(avatars.prefix(maxVisible).enumerated().allSatisfy { $0.0 < index } ? 0 : 1)
                .zIndex(Double(avatars.count - index))
                .onTapGesture {
                    onTap?(index)
                }
            }

            // オーバーフロー表示
            if avatars.count > maxVisible {
                if let count = overflowCount ?? (avatars.count - maxVisible) {
                    OverflowAvatar(
                        count: count,
                        size: size,
                        style: style
                    )
                    .onTapGesture {
                        onOverflowTap?()
                    }
                }
            }
        }
    }
}

// MARK: - Avatar Group Item
struct AvatarGroupItem: Identifiable, Equatable {
    let id: String = UUID().uuidString
    let image: Image?
    let initials: String
    var color: Color?

    init(image: Image? = nil, initials: String, color: Color? = nil) {
        self.image = image
        self.initials = initials
        self.color = color
    }

    static func == (lhs: AvatarGroupItem, rhs: AvatarGroupItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Overflow Avatar
struct OverflowAvatar: View {
    let count: Int
    var size: CGFloat
    var style: AvatarGroupStyle

    var body: some View {
        ZStack {
            Circle()
                .fill(style.overflowColor)
                .frame(width: size, height: size)

            Text(overflowText)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(
                    Color(.systemBackground),
                    lineWidth: style.borderWidth
                )
        )
    }

    private var overflowText: String {
        if count > 99 {
            return "99+"
        }
        return "+\(count)"
    }
}

// MARK: - Avatar Group Style
enum AvatarGroupStyle {
    case standard
    case minimal
    case outlined
    case filled

    var avatarStyle: AvatarViewStyle {
        switch self {
        case .standard:
            return .standard
        case .minimal:
            return .minimal
        case .outlined:
            return .outlined
        case .filled:
            return .filled
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .standard:
            return 3
        case .minimal:
            return 2
        case .outlined:
            return 2
        case .filled:
            return 3
        }
    }

    var overflowColor: Color {
        switch self {
        case .standard:
            return Color(.systemGray3)
        case .minimal:
            return Color(.systemGray4)
        case .outlined:
            return Color.accentColor
        case .filled:
            return Color.accentColor
        }
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let image: Image?
    let initials: String
    var color: Color?
    var size: CGFloat = 40
    var style: AvatarViewStyle = .standard
    var badge: AvatarBadge? = nil

    @State private var isPressed: Bool = false

    var body: some View {
        ZStack {
            // 背景
            Circle()
                .fill(backgroundColor)
                .frame(width: size, height: size)

            // 画像またはイニシャル
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(textColor)
            }

            // バッジ
            if let badge = badge {
                AvatarBadgeView(badge: badge, size: size)
            }
        }
        .overlay(
            style == .outlined ? RoundedRectangle(cornerRadius: size / 2)
                .stroke(Color.accentColor, lineWidth: 2) : nil
        )
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onTapGesture {
            // タップフィードバック
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
        }
        .pressEvents(
            onPressBegin: { isPressed = true },
            onPressEnd: { isPressed = false }
        )
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .drawingGroup()
    }

    private var backgroundColor: Color {
        if let color = color {
            return color
        }
        switch style {
        case .standard:
            return Color(.systemGray5)
        case .minimal:
            return Color(.systemGray6)
        case .outlined:
            return Color(.systemGray5)
        case .filled:
            return Color.accentColor.opacity(0.2)
        }
    }

    private var textColor: Color {
        if let color = color {
            return .white
        }
        switch style {
        case .standard:
            return .primary
        case .minimal:
            return .secondary
        case .outlined:
            return .primary
        case .filled:
            return .accentColor
        }
    }
}

// MARK: - Avatar Badge
struct AvatarBadge {
    let type: BadgeType
    let count: Int?

    init(type: BadgeType, count: Int? = nil) {
        self.type = type
        self.count = count
    }
}

// MARK: - Badge Type
enum BadgeType {
    case online
    case offline
    case busy
    case notification

    var color: Color {
        switch self {
        case .online:
            return .green
        case .offline:
            return .gray
        case .busy:
            return .red
        case .notification:
            return .orange
        }
    }
}

// MARK: - Avatar Badge View
struct AvatarBadgeView: View {
    let badge: AvatarBadge
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(badge.type.color)
                .frame(width: badgeSize, height: badgeSize)

            if let count = badge.count {
                Text(badgeText(count))
                    .font(.system(size: badgeSize * 0.6, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .offset(x: size * 0.35, y: -size * 0.35)
    }

    private var badgeSize: CGFloat {
        if badge.count != nil {
            return size * 0.45
        }
        return size * 0.25
    }

    private func badgeText(_ count: Int) -> String {
        count > 99 ? "99+" : "\(count)"
    }
}

// MARK: - Avatar View Style
enum AvatarViewStyle {
    case standard
    case minimal
    case outlined
    case filled
}

// MARK: - Press Events Modifier
struct PressEventsModifier: ViewModifier {
    var onPressBegin: () -> Void
    var onPressEnd: () -> Void

    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            onPressBegin()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onPressEnd()
                    }
            )
    }
}

extension View {
    func pressEvents(
        onPressBegin: @escaping () -> Void = {},
        onPressEnd: @escaping () -> Void = {}
    ) -> some View {
        modifier(PressEventsModifier(onPressBegin: onPressBegin, onPressEnd: onPressEnd))
    }
}

// MARK: - SwiftUI Previews
#Preview("Standard Avatar Group") {
    VStack(spacing: 30) {
        Text("標準アバターグループ")
            .font(.headline)

        AvatarGroup(
            avatars: [
                AvatarGroupItem(initials: "AB", color: .blue),
                AvatarGroupItem(initials: "CD", color: .green),
                AvatarGroupItem(initials: "EF", color: .orange),
                AvatarGroupItem(initials: "GH", color: .purple),
                AvatarGroupItem(initials: "IJ", color: .pink),
            ],
            style: .standard,
            size: 40
        )

        AvatarGroup(
            avatars: Array(0..<8).map { i in
                AvatarGroupItem(initials: "\(i)A", color: .blue)
            },
            style: .standard,
            size: 40,
            maxVisible: 4
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Minimal Avatar Group") {
    VStack(spacing: 30) {
        Text("ミニマルアバターグループ")
            .font(.headline)

        AvatarGroup(
            avatars: [
                AvatarGroupItem(initials: "AB"),
                AvatarGroupItem(initials: "CD"),
                AvatarGroupItem(initials: "EF"),
            ],
            style: .minimal,
            size: 32
        )

        AvatarGroup(
            avatars: Array(0..<6).map { i in
                AvatarGroupItem(initials: "\(i)A")
            },
            style: .minimal,
            size: 32,
            maxVisible: 3
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Outlined Avatar Group") {
    VStack(spacing: 30) {
        Text("アウトラインアバターグループ")
            .font(.headline)

        AvatarGroup(
            avatars: [
                AvatarGroupItem(initials: "AB", color: .blue),
                AvatarGroupItem(initials: "CD", color: .green),
                AvatarGroupItem(initials: "EF", color: .orange),
            ],
            style: .outlined,
            size: 48
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Filled Avatar Group") {
    VStack(spacing: 30) {
        Text("フィルドアバターグループ")
            .font(.headline)

        AvatarGroup(
            avatars: [
                AvatarGroupItem(initials: "AB", color: .blue),
                AvatarGroupItem(initials: "CD", color: .green),
                AvatarGroupItem(initials: "EF", color: .orange),
                AvatarGroupItem(initials: "GH", color: .purple),
            ],
            style: .filled,
            size: 44
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Avatar with Badges") {
    VStack(spacing: 30) {
        Text("バッジ付きアバター")
            .font(.headline)

        HStack(spacing: 20) {
            AvatarView(
                image: nil,
                initials: "AB",
                color: .blue,
                size: 50,
                badge: AvatarBadge(type: .online)
            )

            AvatarView(
                image: nil,
                initials: "CD",
                color: .green,
                size: 50,
                badge: AvatarBadge(type: .busy)
            )

            AvatarView(
                image: nil,
                initials: "EF",
                color: .orange,
                size: 50,
                badge: AvatarBadge(type: .offline)
            )

            AvatarView(
                image: nil,
                initials: "GH",
                color: .purple,
                size: 50,
                badge: AvatarBadge(type: .notification, count: 3)
            )

            AvatarView(
                image: nil,
                initials: "IJ",
                color: .pink,
                size: 50,
                badge: AvatarBadge(type: .notification, count: 99)
            )
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Various Sizes") {
    VStack(spacing: 30) {
        Text("様々なサイズ")
            .font(.headline)

        VStack(spacing: 15) {
            HStack {
                Text("Small (24px)")
                    .frame(width: 100, alignment: .leading)
                AvatarGroup(
                    avatars: [
                        AvatarGroupItem(initials: "AB", color: .blue),
                        AvatarGroupItem(initials: "CD", color: .green),
                    ],
                    size: 24
                )
            }

            HStack {
                Text("Medium (40px)")
                    .frame(width: 100, alignment: .leading)
                AvatarGroup(
                    avatars: [
                        AvatarGroupItem(initials: "AB", color: .blue),
                        AvatarGroupItem(initials: "CD", color: .green),
                        AvatarGroupItem(initials: "EF", color: .orange),
                    ],
                    size: 40
                )
            }

            HStack {
                Text("Large (56px)")
                    .frame(width: 100, alignment: .leading)
                AvatarGroup(
                    avatars: [
                        AvatarGroupItem(initials: "AB", color: .blue),
                        AvatarGroupItem(initials: "CD", color: .green),
                        AvatarGroupItem(initials: "EF", color: .orange),
                    ],
                    size: 56
                )
            }

            HStack {
                Text("XLarge (72px)")
                    .frame(width: 100, alignment: .leading)
                AvatarGroup(
                    avatars: [
                        AvatarGroupItem(initials: "AB", color: .blue),
                        AvatarGroupItem(initials: "CD", color: .green),
                    ],
                    size: 72
                )
            }
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Interactive Avatar Group") {
    VStack(spacing: 30) {
        Text("インタラクティブアバターグループ")
            .font(.headline)

        AvatarGroup(
            avatars: Array(0..<5).map { i in
                AvatarGroupItem(initials: "\(i)A", color: .blue)
            },
            size: 48,
            maxVisible: 4,
            onTap: { index in
                print("Tapped avatar at index: \(index)")
            },
            onOverflowTap: {
                print("Tapped overflow")
            }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Custom Spacing") {
    VStack(spacing: 30) {
        Text("カスタム間隔")
            .font(.headline)

        VStack(spacing: 15) {
            HStack {
                Text("None (0px)")
                    .frame(width: 120, alignment: .leading)
                AvatarGroup(
                    avatars: [
                        AvatarGroupItem(initials: "AB", color: .blue),
                        AvatarGroupItem(initials: "CD", color: .green),
                        AvatarGroupItem(initials: "EF", color: .orange),
                    ],
                    spacing: 0
                )
            }

            HStack {
                Text("Standard (-10px)")
                    .frame(width: 120, alignment: .leading)
                AvatarGroup(
                    avatars: [
                        AvatarGroupItem(initials: "AB", color: .blue),
                        AvatarGroupItem(initials: "CD", color: .green),
                        AvatarGroupItem(initials: "EF", color: .orange),
                    ],
                    spacing: -10
                )
            }

            HStack {
                Text("Wide (-5px)")
                    .frame(width: 120, alignment: .leading)
                AvatarGroup(
                    avatars: [
                        AvatarGroupItem(initials: "AB", color: .blue),
                        AvatarGroupItem(initials: "CD", color: .green),
                        AvatarGroupItem(initials: "EF", color: .orange),
                    ],
                    spacing: -5
                )
            }
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
