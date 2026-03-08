import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var navigationViewModel = NavigationViewModel.shared
    @Namespace private var animation

    var body: some View {
        TabView(selection: $navigationViewModel.selectedTab) {
            LearningLogView()
                .tabItem {
                    Label("学習ログ", systemImage: "book.fill")
                }
                .tag(0)
                .accessibilityIdentifier("learningLogTab")

            PortfolioView()
                .tabItem {
                    Label("ポートフォリオ", systemImage: "person.fill")
                }
                .tag(1)
                .accessibilityIdentifier("portfolioTab")

            AIChatView()
                .tabItem {
                    Label("AI壁打ち", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(2)
                .accessibilityIdentifier("aiChatTab")

            ProfileView()
                .tabItem {
                    Label("プロフィール", systemImage: "gearshape.fill")
                }
                .tag(3)
                .accessibilityIdentifier("profileTab")
        }
        .animation(.easeInOut(duration: 0.25), value: navigationViewModel.selectedTab)
        .onChange(of: navigationViewModel.selectedTab) { oldValue, newValue in
            HapticFeedback.light() // タブ切替
        }
        .onAppear {
            // ナビゲーション状態を復元
            Task {
                await navigationViewModel.restoreNavigationState()
            }
        }
        .onDisappear {
            // アプリがバックグラウンドに移行する前に状態を保存
            Task {
                await navigationViewModel.saveNavigationStateImmediately()
            }
        }
        .tint(.pink)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("メインナビゲーション")
        .disabled(navigationViewModel.isNavigationRestoring)
        .overlay {
            if navigationViewModel.isNavigationRestoring {
                LoadingView(message: "復元中...")
                    .background(Color(UIColor.systemBackground))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarMenuButton(
                    profile: authViewModel.profile,
                    selectedTab: navigationViewModel.selectedTab,
                    onSignOut: {
                        Task {
                            await authViewModel.signOut()
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}

// MARK: - Toolbar Menu Button

struct ToolbarMenuButton: View {
    let profile: UserProfile?
    let selectedTab: Int
    let onSignOut: () -> Void
    @State private var isPressed = false

    var body: some View {
        Menu {
            Button(role: .destructive) {
                onSignOut()
            } label: {
                Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            if let profile = profile, let avatarIcon = profile.avatarIcon {
                Image(systemName: avatarIcon)
                    .foregroundColor(.pink)
                    .symbolEffect(.bounce, value: selectedTab)
            } else {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.pink)
                    .symbolEffect(.bounce, value: selectedTab)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityLabel("ユーザーメニュー")
        .accessibilityHint("ログアウトなどの操作ができます")
    }
}
