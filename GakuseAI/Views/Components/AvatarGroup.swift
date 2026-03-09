//
//  AvatarGroup.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-09.
//

import SwiftUI

// MARK: - Avatar Group
struct AvatarGroup: View {
    var avatars: [AvatarInfo]
    var size: AvatarGroupSize = .medium
    var style: AvatarGroupStyle = .standard
    var spacing: CGFloat = 8
    var maxVisible: Int = 5
    var showMoreIndicator: Bool = true
    var onTapAvatar: ((AvatarInfo) -> Void)? = nil
    var onTapMore: (() -> Void)? = nil

    @State private var pressedAvatarIndex: Int? = nil

    private var visibleAvatars: [AvatarInfo] {
        Array(avatars.prefix(maxVisible))
    }

    private var remainingCount: Int {
        max(0, avatars.count - maxVisible)
    }

    private var avatarSize: CGFloat {
        switch size {
        case .small:
            return 28
        case .medium:
            return 36
        case .large:
            return 44
        }
    }

    private var fontSize: CGFloat {
        switch size {
        case .small:
            return 10
        case .medium:
            return 12
        case .large:
            return 14
        }
    }

    private var overlapOffset: CGFloat {
        avatarSize * 0.35
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(visibleAvatars.enumerated()), id: \.offset) { index, avatar in
                avatarView(for: avatar, index: index)
                    .offset(x: CGFloat(index) * -overlapOffset)
                    .zIndex(Double(visibleAvatars.count - index))
            }

            if remainingCount > 0 && showMoreIndicator {
                moreIndicatorView
                    .offset(x: CGFloat(visibleAvatars.count) * -overlapOffset)
                    .zIndex(0)
            }
        }
        .drawingGroup() // パフォーマンス最適化：レイヤー合成削減
    }

    @ViewBuilder
    private func avatarView(for avatar: AvatarInfo, index: Int) -> some View {
        if let imageUrl = avatar.imageUrl {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                placeholderView(for: avatar)
            }
            .frame(width: avatarSize, height: avatarSize)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(style.borderColor(for: avatar), lineWidth: style.borderWidth)
            )
            .contentShape(Circle())
            .scaleEffect(pressedAvatarIndex == index ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressedAvatarIndex)
            .onTapGesture {
                if let onTapAvatar = onTapAvatar {
                    onTapAvatar(avatar)
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        pressedAvatarIndex = index
                    }
                    .onEnded { _ in
                        pressedAvatarIndex = nil
                        let feedback = UIImpactFeedbackGenerator(style: .light)
                        feedback.impactOccurred()
                    }
            )
        } else {
            placeholderView(for: avatar)
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(style.borderColor(for: avatar), lineWidth: style.borderWidth)
                )
                .contentShape(Circle())
                .scaleEffect(pressedAvatarIndex == index ? 0.9 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressedAvatarIndex)
                .onTapGesture {
                    if let onTapAvatar = onTapAvatar {
                        onTapAvatar(avatar)
                    }
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            pressedAvatarIndex = index
                        }
                        .onEnded { _ in
                            pressedAvatarIndex = nil
                            let feedback = UIImpactFeedbackGenerator(style: .light)
                            feedback.impactOccurred()
                        }
                )
        }
    }

    @ViewBuilder
    private func placeholderView(for avatar: AvatarInfo) -> some View {
        ZStack {
            Circle()
                .fill(avatar.backgroundColor)

            if let initials = avatar.initials {
                Text(initials)
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(avatar.textColor)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: fontSize * 1.2))
                    .foregroundColor(avatar.textColor)
            }

            // オンラインステータス
            if avatar.isOnline && style.showsOnlineStatus {
                Circle()
                    .fill(Color.green)
                    .frame(width: avatarSize * 0.25, height: avatarSize * 0.25)
                    .offset(x: avatarSize * 0.35, y: avatarSize * 0.35)
            }
        }
    }

    @ViewBuilder
    private var moreIndicatorView: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray5))

            Text("+\(remainingCount)")
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(width: avatarSize, height: avatarSize)
        .overlay(
            Circle()
                .stroke(style.borderColor(for: nil), lineWidth: style.borderWidth)
        )
        .contentShape(Circle())
        .scaleEffect(pressedAvatarIndex == -1 ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressedAvatarIndex)
        .onTapGesture {
            if let onTapMore = onTapMore {
                onTapMore()
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    pressedAvatarIndex = -1
                }
                .onEnded { _ in
                    pressedAvatarIndex = nil
                    let feedback = UIImpactFeedbackGenerator(style: .light)
                    feedback.impactOccurred()
                }
        )
    }
}

// MARK: - Avatar Group Size
enum AvatarGroupSize {
    case small
    case medium
    case large
}

// MARK: - Avatar Group Style
enum AvatarGroupStyle {
    case standard
    case elevated
    case minimal
    case colored

    var borderWidth: CGFloat {
        switch self {
        case .standard:
            return 2
        case .elevated:
            return 3
        case .minimal:
            return 1
        case .colored:
            return 2
        }
    }

    var showsOnlineStatus: Bool {
        switch self {
        case .standard:
            return true
        case .elevated:
            return true
        case .minimal:
            return false
        case .colored:
            return true
        }
    }

    func borderColor(for avatar: AvatarInfo?) -> Color {
        switch self {
        case .standard:
            return Color(.systemBackground)
        case .elevated:
            return Color(.systemBackground)
        case .minimal:
            return Color(.systemGray4)
        case .colored:
            if let avatar = avatar {
                return avatar.backgroundColor
            }
            return Color(.systemGray4)
        }
    }
}

// MARK: - Avatar Info
struct AvatarInfo: Identifiable {
    let id: String
    let name: String
    let imageUrl: String?
    let initials: String?
    let backgroundColor: Color
    let textColor: Color
    let isOnline: Bool

    init(
        id: String,
        name: String,
        imageUrl: String? = nil,
        initials: String? = nil,
        backgroundColor: Color = .blue,
        textColor: Color = .white,
        isOnline: Bool = false
    ) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.initials = initials ?? AvatarInfo.generateInitials(from: name)
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.isOnline = isOnline
    }

    private static func generateInitials(from name: String) -> String {
        let parts = name.components(separatedBy: " ")
            .filter { !$0.isEmpty }
        if parts.count >= 2 {
            return String(parts[0].prefix(1)) + String(parts[1].prefix(1))
        } else if let first = parts.first {
            return String(first.prefix(2))
        }
        return "?"
    }
}

// MARK: - SwiftUI Previews
#Preview("Standard Avatar Group") {
    VStack(spacing: 30) {
        Text("標準アバターグループ")
            .font(.headline)

        AvatarGroup(
            avatars: sampleAvatars.prefix(5).map { $0 },
            size: .medium,
            style: .standard,
            maxVisible: 5
        )

        AvatarGroup(
            avatars: sampleAvatars,
            size: .large,
            style: .standard,
            maxVisible: 4
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Elevated Avatar Group") {
    VStack(spacing: 30) {
        Text("エレベーテッドアバターグループ")
            .font(.headline)

        AvatarGroup(
            avatars: sampleAvatars.prefix(4).map { $0 },
            size: .medium,
            style: .elevated,
            maxVisible: 4
        )

        AvatarGroup(
            avatars: sampleAvatars,
            size: .small,
            style: .elevated,
            maxVisible: 6
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
            avatars: sampleAvatars.prefix(3).map { $0 },
            size: .small,
            style: .minimal,
            maxVisible: 3
        )

        AvatarGroup(
            avatars: sampleAvatars,
            size: .medium,
            style: .minimal,
            maxVisible: 5
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Colored Avatar Group") {
    VStack(spacing: 30) {
        Text("カラードアバターグループ")
            .font(.headline)

        AvatarGroup(
            avatars: coloredAvatars.prefix(4).map { $0 },
            size: .medium,
            style: .colored,
            maxVisible: 4
        )

        AvatarGroup(
            avatars: coloredAvatars,
            size: .large,
            style: .colored,
            maxVisible: 5
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("With Online Status") {
    VStack(spacing: 30) {
        Text("オンラインステータス表示")
            .font(.headline)

        AvatarGroup(
            avatars: onlineAvatars,
            size: .medium,
            style: .standard,
            maxVisible: 5
        )

        AvatarGroup(
            avatars: onlineAvatars,
            size: .large,
            style: .elevated,
            maxVisible: 4
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Various Sizes") {
    VStack(spacing: 40) {
        Text("様々なサイズ")
            .font(.headline)

        AvatarGroup(
            avatars: sampleAvatars.prefix(3).map { $0 },
            size: .small,
            style: .standard,
            maxVisible: 3
        )

        AvatarGroup(
            avatars: sampleAvatars.prefix(4).map { $0 },
            size: .medium,
            style: .standard,
            maxVisible: 4
        )

        AvatarGroup(
            avatars: sampleAvatars.prefix(5).map { $0 },
            size: .large,
            style: .standard,
            maxVisible: 5
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

// MARK: - Sample Data
private let sampleAvatars: [AvatarInfo] = [
    AvatarInfo(
        id: "1",
        name: "田中 太郎",
        imageUrl: nil,
        initials: "田太",
        backgroundColor: .blue,
        textColor: .white,
        isOnline: true
    ),
    AvatarInfo(
        id: "2",
        name: "山田 花子",
        imageUrl: nil,
        initials: "山花",
        backgroundColor: .purple,
        textColor: .white,
        isOnline: false
    ),
    AvatarInfo(
        id: "3",
        name: "佐藤 次郎",
        imageUrl: nil,
        initials: "佐次",
        backgroundColor: .green,
        textColor: .white,
        isOnline: true
    ),
    AvatarInfo(
        id: "4",
        name: "鈴木 美咲",
        imageUrl: nil,
        initials: "鈴美",
        backgroundColor: .orange,
        textColor: .white,
        isOnline: false
    ),
    AvatarInfo(
        id: "5",
        name: "高橋 健一",
        imageUrl: nil,
        initials: "高健",
        backgroundColor: .red,
        textColor: .white,
        isOnline: true
    ),
    AvatarInfo(
        id: "6",
        name: "伊藤 真由美",
        imageUrl: nil,
        initials: "伊真",
        backgroundColor: .pink,
        textColor: .white,
        isOnline: false
    )
]

private let coloredAvatars: [AvatarInfo] = [
    AvatarInfo(
        id: "1",
        name: "Red User",
        imageUrl: nil,
        initials: "RU",
        backgroundColor: .red,
        textColor: .white,
        isOnline: true
    ),
    AvatarInfo(
        id: "2",
        name: "Blue User",
        imageUrl: nil,
        initials: "BU",
        backgroundColor: .blue,
        textColor: .white,
        isOnline: false
    ),
    AvatarInfo(
        id: "3",
        name: "Green User",
        imageUrl: nil,
        initials: "GU",
        backgroundColor: .green,
        textColor: .white,
        isOnline: true
    ),
    AvatarInfo(
        id: "4",
        name: "Yellow User",
        imageUrl: nil,
        initials: "YU",
        backgroundColor: .yellow,
        textColor: .black,
        isOnline: false
    ),
    AvatarInfo(
        id: "5",
        name: "Purple User",
        imageUrl: nil,
        initials: "PU",
        backgroundColor: .purple,
        textColor: .white,
        isOnline: true
    )
]

private let onlineAvatars: [AvatarInfo] = [
    AvatarInfo(
        id: "1",
        name: "Online User 1",
        imageUrl: nil,
        initials: "OU",
        backgroundColor: .blue,
        textColor: .white,
        isOnline: true
    ),
    AvatarInfo(
        id: "2",
        name: "Online User 2",
        imageUrl: nil,
        initials: "OU",
        backgroundColor: .green,
        textColor: .white,
        isOnline: true
    ),
    AvatarInfo(
        id: "3",
        name: "Offline User",
        imageUrl: nil,
        initials: "OF",
        backgroundColor: .gray,
        textColor: .white,
        isOnline: false
    ),
    AvatarInfo(
        id: "4",
        name: "Online User 4",
        imageUrl: nil,
        initials: "OU",
        backgroundColor: .purple,
        textColor: .white,
        isOnline: true
    ),
    AvatarInfo(
        id: "5",
        name: "Online User 5",
        imageUrl: nil,
        initials: "OU",
        backgroundColor: .orange,
        textColor: .white,
        isOnline: true
    )
]
