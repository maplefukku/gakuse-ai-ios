import SwiftUI

// MARK: - Profile Button Content

struct ProfileButtonContent: View {
    let profile: UserProfile?
    @State private var isPressed = false

    var body: some View {
        HStack {
            AvatarView(name: profile?.name, avatarIcon: profile?.avatarIcon, size: .medium)

            ProfileInfoView(profile: profile)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .foregroundColor(.primary)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Profile Info View

struct ProfileInfoView: View {
    let profile: UserProfile?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(displayName)
                .font(.headline)

            Text(displayEmail)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var displayName: String {
        profile?.name ?? "ユーザー"
    }

    private var displayEmail: String {
        if let email = profile?.email {
            return email
        } else {
            return "メールアドレス未設定"
        }
    }
}
