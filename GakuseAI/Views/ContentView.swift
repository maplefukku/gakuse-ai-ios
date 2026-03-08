import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
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
        .onChange(of: selectedTab) { oldValue, newValue in
            HapticFeedback.light() // タブ切替
        }
        .tint(.pink)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("メインナビゲーション")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        Task {
                            await authViewModel.signOut()
                        }
                    } label: {
                        Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    if let profile = authViewModel.profile, let avatarIcon = profile.avatarIcon {
                        Image(systemName: avatarIcon)
                            .foregroundColor(.pink)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.pink)
                    }
                }
                .accessibilityLabel("ユーザーメニュー")
                .accessibilityHint("ログアウトなどの操作ができます")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
