import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            LearningLogView()
                .tabItem {
                    Label("学習ログ", systemImage: "book.fill")
                }
                .accessibilityIdentifier("learningLogTab")

            PortfolioView()
                .tabItem {
                    Label("ポートフォリオ", systemImage: "person.fill")
                }
                .accessibilityIdentifier("portfolioTab")

            AIChatView()
                .tabItem {
                    Label("AI壁打ち", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .accessibilityIdentifier("aiChatTab")

            ProfileView()
                .tabItem {
                    Label("プロフィール", systemImage: "gearshape.fill")
                }
                .accessibilityIdentifier("profileTab")
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
