import SwiftUI

// MARK: - Profile Card Component

struct ProfileCard: View {
    let name: String
    let subtitle: String?
    let avatarGradient: [Color] = [.pink, .purple]
    var showEditButton: Bool = false
    var onEdit: (() -> Void)? = nil
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: avatarGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 100, height: 100)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                .shadow(color: .pink.opacity(0.3), radius: 10)

            // Name
            Text(name)
                .font(.title2.bold())
                .foregroundColor(.primary)

            // Subtitle
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Edit Button
            if showEditButton, let onEdit = onEdit {
                Button(action: onEdit) {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                        Text("編集")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
                    .shadow(color: .pink.opacity(0.2), radius: 5)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                    withAnimation {
                        isPressed = pressing
                    }
                }, perform: {})
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .drawingGroup() // パフォーマンス最適化
        .accessibilityElement(children: .combine)
        .accessibilityLabel("プロフィールカード")
        .accessibilityHint("\(name)のプロフィール情報を表示します")
    }
}

// MARK: - Mini Profile Card

struct MiniProfileCard: View {
    let name: String
    let avatarGradient: [Color] = [.pink, .purple]
    var onTap: (() -> Void)? = nil
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: avatarGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }

            // Name
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            // Arrow
            if onTap != nil {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
            onTap?()
        }
        .drawingGroup() // パフォーマンス最適化
        .accessibilityElement(children: .combine)
        .accessibilityLabel("プロフィール")
        .accessibilityHint("\(name)のプロフィール詳細を表示します")
    }
}

// MARK: - Preview

#Preview("Profile Card") {
    ProfileCard(
        name: "田中太郎",
        subtitle: "iOSエンジニア",
        showEditButton: true,
        onEdit: {
            print("Edit tapped")
        }
    )
    .padding()
}

#Preview("Mini Profile Card") {
    VStack(spacing: 16) {
        MiniProfileCard(
            name: "田中太郎",
            onTap: {
                print("Profile tapped")
            }
        )

        MiniProfileCard(
            name: "山田花子"
        )
    }
    .padding()
}
