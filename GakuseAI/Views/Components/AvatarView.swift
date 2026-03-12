import SwiftUI

// MARK: - Avatar Info Model

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

// MARK: - Avatar View Component

struct AvatarView: View {
    let name: String
    let avatarImage: String?
    let size: AvatarSize
    let gradient: [Color]?
    let onTap: (() -> Void)?
    @State private var isPressed = false

    enum AvatarSize {
        case small
        case medium
        case large
        case xLarge

        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 48
            case .large: return 64
            case .xLarge: return 96
            }
        }

        var fontSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .title3
            case .xLarge: return .title
            }
        }
    }

    init(
        name: String,
        avatarImage: String? = nil,
        size: AvatarSize = .medium,
        gradient: [Color]? = [.pink, .purple],
        onTap: (() -> Void)? = nil
    ) {
        self.name = name
        self.avatarImage = avatarImage
        self.size = size
        self.gradient = gradient
        self.onTap = onTap
    }

    /// プロファイル用のコンビニエンスイニシャライザ
    /// ProfileAvatarViewの置換用
    init(
        name: String? = nil,
        avatarIcon: String? = nil,
        size: AvatarSize = .medium
    ) {
        self.name = name ?? "User"
        self.avatarImage = avatarIcon
        self.size = size
        self.gradient = [.pink, .purple]
        self.onTap = nil
    }

    private var initials: String {
        let components = name.components(separatedBy: " ")
        let first = components.first?.prefix(1) ?? ""
        let last = components.count > 1 ? components.last?.prefix(1) ?? "" : ""
        return (first + last).uppercased()
    }

    var body: some View {
        Group {
            if let avatarImage = avatarImage {
                // SF Symbol based avatar
                Image(systemName: avatarImage)
                    .font(size.fontSize)
                    .foregroundColor(.white)
                    .frame(width: size.dimension, height: size.dimension)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: gradient ?? [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .pink.opacity(0.3), radius: 4)
            } else {
                // Initials based avatar
                Text(initials)
                    .font(size.fontSize)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: size.dimension, height: size.dimension)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: gradient ?? [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .pink.opacity(0.3), radius: 4)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .contentShape(Circle())
        .onTapGesture {
            onTap?()
        }
        .drawingGroup() // パフォーマンス最適化
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name)のアバター")
        .accessibilityHint(onTap != nil ? "タップして詳細を表示" : "")
        .accessibilityAddTraits(onTap != nil ? [.isButton] : [])
    }
}

// MARK: - Profile Avatar Convenience Initializer

extension AvatarView {
    /// プロファイル用のアバタービューを作成
    /// - Parameters:
    ///   - avatarIcon: アバターアイコン（SF Symbol名）
    ///   - name: ユーザー名
    ///   - size: アバターサイズ（デフォルト: .large）
    /// - Returns: プロファイル用にカスタマイズされたAvatarView
    static func profile(
        avatarIcon: String? = nil,
        name: String?,
        size: AvatarSize = .large
    ) -> AvatarView {
        AvatarView(
            name: name ?? "Unknown",
            avatarImage: avatarIcon,
            size: size,
            gradient: [.pink, .purple],
            onTap: nil
        )
    }
}

// MARK: - Avatar With Status Component

struct AvatarWithStatus: View {
    let name: String
    let avatarImage: String?
    let status: UserStatus
    let size: AvatarView.AvatarSize

    enum UserStatus: String, CaseIterable {
        case online = "online"
        case away = "away"
        case busy = "busy"
        case offline = "offline"

        var color: Color {
            switch self {
            case .online: return .green
            case .away: return .yellow
            case .busy: return .red
            case .offline: return .gray
            }
        }

        var label: String {
            switch self {
            case .online: return "オンライン"
            case .away: return "退席中"
            case .busy: return "取り込み中"
            case .offline: return "オフライン"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AvatarView(
                name: name,
                avatarImage: avatarImage,
                size: size
            )

            Circle()
                .fill(status.color)
                .frame(width: size.dimension * 0.3, height: size.dimension * 0.3)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .offset(x: -size.dimension * 0.1, y: -size.dimension * 0.1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name) - \(status.label)")
    }
}

// MARK: - Preview

#Preview("Avatar View - Small") {
    HStack(spacing: 16) {
        AvatarView(name: "田中", size: .small)
        AvatarView(name: "山田", avatarImage: "person.circle.fill", size: .small)
    }
    .padding()
}

#Preview("Avatar View - Medium") {
    HStack(spacing: 16) {
        AvatarView(name: "田中太郎", size: .medium)
        AvatarView(name: "山田花子", avatarImage: "person.circle.fill", size: .medium)
    }
    .padding()
}

#Preview("Avatar View - Large") {
    HStack(spacing: 16) {
        AvatarView(name: "田中太郎", size: .large)
        AvatarView(name: "山田花子", avatarImage: "person.circle.fill", size: .large)
    }
    .padding()
}

#Preview("Avatar View - X Large") {
    HStack(spacing: 16) {
        AvatarView(name: "田中太郎", size: .xLarge)
        AvatarView(name: "山田花子", avatarImage: "person.circle.fill", size: .xLarge)
    }
    .padding()
}

#Preview("Avatar View - Custom Gradient") {
    HStack(spacing: 16) {
        AvatarView(
            name: "田中太郎",
            size: .large,
            gradient: [.blue, .cyan]
        )
        AvatarView(
            name: "山田花子",
            avatarImage: "star.fill",
            size: .large,
            gradient: [.orange, .yellow]
        )
    }
    .padding()
}

#Preview("Avatar With Status") {
    VStack(spacing: 24) {
        HStack(spacing: 16) {
            AvatarWithStatus(name: "田中", avatarImage: nil, status: AvatarWithStatus.UserStatus.online, size: .large)
            AvatarWithStatus(name: "山田", avatarImage: nil, status: AvatarWithStatus.UserStatus.away, size: .large)
            AvatarWithStatus(name: "佐藤", avatarImage: nil, status: AvatarWithStatus.UserStatus.busy, size: .large)
            AvatarWithStatus(name: "鈴木", avatarImage: nil, status: AvatarWithStatus.UserStatus.offline, size: .large)
        }

        HStack(spacing: 16) {
            AvatarWithStatus(
                name: "田中",
                avatarImage: "person.circle.fill",
                status: AvatarWithStatus.UserStatus.online,
                size: .xLarge
            )
        }
    }
    .padding()
}
