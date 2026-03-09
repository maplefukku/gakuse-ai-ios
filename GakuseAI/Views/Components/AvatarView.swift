import SwiftUI

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

// MARK: - Avatar Group (Multiple Avatars)

struct AvatarGroup: View {
    let names: [String]
    let avatarImages: [String?]
    let size: AvatarView.AvatarSize
    let maxVisible: Int
    let remainingColor: Color
    let onAvatarTap: ((Int) -> Void)?

    init(
        names: [String],
        avatarImages: [String?] = [],
        size: AvatarView.AvatarSize = .medium,
        maxVisible: Int = 3,
        remainingColor: Color = .gray,
        onAvatarTap: ((Int) -> Void)? = nil
    ) {
        self.names = names
        self.avatarImages = avatarImages.isEmpty ? Array(repeating: nil, count: names.count) : avatarImages
        self.size = size
        self.maxVisible = maxVisible
        self.remainingColor = remainingColor
        self.onAvatarTap = onAvatarTap
    }

    var body: some View {
        HStack(spacing: -8) {
            ForEach(0..<min(names.count, maxVisible), id: \.self) { index in
                AvatarView(
                    name: names[index],
                    avatarImage: index < avatarImages.count ? avatarImages[index] : nil,
                    size: size
                )
                .overlay(
                    Circle()
                        .stroke(Color(UIColor.systemBackground), lineWidth: 2)
                )
                .onTapGesture {
                    onAvatarTap?(index)
                }
            }

            if names.count > maxVisible {
                ZStack {
                    Circle()
                        .fill(remainingColor.opacity(0.2))
                        .frame(width: size.dimension, height: size.dimension)

                    Text("+\(names.count - maxVisible)")
                        .font(size.fontSize)
                        .fontWeight(.semibold)
                        .foregroundColor(remainingColor)
                }
                .overlay(
                    Circle()
                        .stroke(Color(UIColor.systemBackground), lineWidth: 2)
                )
            }
        }
        .drawingGroup() // パフォーマンス最適化
    }
}

// MARK: - Avatar With Status

struct AvatarWithStatus: View {
    let name: String
    let avatarImage: String?
    let size: AvatarView.AvatarSize
    let status: UserStatus
    let gradient: [Color]?
    let onTap: (() -> Void)?

    enum UserStatus {
        case online
        case away
        case busy
        case offline

        var color: Color {
            switch self {
            case .online: return .green
            case .away: return .orange
            case .busy: return .red
            case .offline: return .gray
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AvatarView(
                name: name,
                avatarImage: avatarImage,
                size: size,
                gradient: gradient,
                onTap: onTap
            )

            // Status indicator
            Circle()
                .fill(status.color)
                .frame(width: size.dimension / 4, height: size.dimension / 4)
                .overlay(
                    Circle()
                        .stroke(Color(UIColor.systemBackground), lineWidth: 2)
                )
                .offset(x: size.dimension / 8, y: size.dimension / 8)
        }
        .drawingGroup() // パフォーマンス最適化
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name)のアバター")
        .accessibilityValue(statusText)
        .accessibilityHint(onTap != nil ? "タップして詳細を表示" : "")
    }

    private var statusText: String {
        switch status {
        case .online: return "オンライン"
        case .away: return "退席中"
        case .busy: return "取り込み中"
        case .offline: return "オフライン"
        }
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
            gradient: [.blue, .cyan],
            size: .large
        )
        AvatarView(
            name: "山田花子",
            avatarImage: "star.fill",
            gradient: [.orange, .yellow],
            size: .large
        )
    }
    .padding()
}

#Preview("Avatar Group") {
    VStack(spacing: 24) {
        AvatarGroup(
            names: ["田中", "山田", "佐藤", "鈴木"],
            size: .medium,
            maxVisible: 3
        )

        AvatarGroup(
            names: ["田中", "山田"],
            size: .large,
            maxVisible: 3
        )
    }
    .padding()
}

#Preview("Avatar With Status") {
    VStack(spacing: 24) {
        HStack(spacing: 16) {
            AvatarWithStatus(name: "田中", status: .online, size: .large)
            AvatarWithStatus(name: "山田", status: .away, size: .large)
            AvatarWithStatus(name: "佐藤", status: .busy, size: .large)
            AvatarWithStatus(name: "鈴木", status: .offline, size: .large)
        }

        HStack(spacing: 16) {
            AvatarWithStatus(
                name: "田中",
                avatarImage: "person.circle.fill",
                status: .online,
                size: .xLarge
            )
        }
    }
    .padding()
}
