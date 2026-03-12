import SwiftUI

// MARK: - Avatar Picker View

struct AvatarPickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @Namespace private var animation

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(Array(AvatarIcon.allCases.enumerated()), id: \.element) { index, icon in
                        AvatarButton(
                            icon: icon,
                            isSelected: viewModel.userProfile?.avatarIcon == icon.rawValue,
                            namespace: animation
                        ) {
                            await selectAvatar(icon)
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                    }
                }
                .padding()
            }
            .navigationTitle("アバター選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .presentationDragIndicator(.visible)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.userProfile?.avatarIcon)
    }

    private func selectAvatar(_ icon: AvatarIcon) async {
        await viewModel.updateProfile(name: viewModel.userProfile?.name ?? "ユーザー", avatarIcon: icon.rawValue)
        dismiss()
    }
}

// MARK: - Avatar Button Component

struct AvatarButton: View {
    let icon: AvatarIcon
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () async -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            ZStack {
                // グラデーション背景
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: shadowColor.opacity(0.3),
                        radius: isPressed ? 4 : (isSelected ? 8 : 4),
                        x: 0,
                        y: isPressed ? 2 : (isSelected ? 4 : 2)
                    )

                // アイコン
                Image(systemName: icon.rawValue)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                // 選択時のチェックマーク
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(checkmarkColor)
                            .font(.title3)
                    }
                    .offset(x: 28, y: -28)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(AvatarButtonStyle(isPressed: $isPressed))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }

    private var gradientColors: [Color] {
        if isSelected {
            return [Color.pink, Color.purple]
        } else {
            return [Color.pink.opacity(0.7), Color.purple.opacity(0.7)]
        }
    }

    private var shadowColor: Color {
        Color.primary.opacity(0.2)
    }

    private var checkmarkColor: Color {
        Color.pink
    }
}

// MARK: - Avatar Button Style

struct AvatarButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : (isPressed ? 0.88 : 1.0))
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Avatar Icon

enum AvatarIcon: String, CaseIterable {
    case person = "person.fill"
    case star = "star.fill"
    case heart = "heart.fill"
    case bolt = "bolt.fill"
    case flame = "flame.fill"
    case cloud = "cloud.fill"
    case sun = "sun.max.fill"
    case moon = "moon.fill"
    case sparkle = "sparkles"
    case trophy = "trophy.fill"
    case rocket = "rocket.fill"

    var displayName: String {
        switch self {
        case .person: return "デフォルト"
        case .star: return "スター"
        case .heart: return "ハート"
        case .bolt: return "雷"
        case .flame: return "炎"
        case .cloud: return "クラウド"
        case .sun: return "太陽"
        case .moon: return "月"
        case .sparkle: return "キラキラ"
        case .trophy: return "トロフィー"
        case .rocket: return "ロケット"
        }
    }
}
