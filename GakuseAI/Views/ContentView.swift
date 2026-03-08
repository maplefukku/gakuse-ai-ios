import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    @State private var isNavigationRestoring = false
    @Namespace private var animation
    
    init() {
        _selectedTab = State(initialValue: 0)
    }

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
        .animation(.easeInOut(duration: 0.25), value: selectedTab)
        .onChange(of: selectedTab) { oldValue, newValue in
            HapticFeedback.light() // タブ切替
            
            // ナビゲーション状態を保存
            Task {
                let state = NavigationState(selectedTab: newValue)
                do {
                    try await PersistenceService.shared.saveNavigationState(state)
                } catch {
                    print("Failed to save navigation state: \(error)")
                }
            }
        }
        .onAppear {
            // ナビゲーション状態を復元
            Task {
                isNavigationRestoring = true
                do {
                    let state = try await PersistenceService.shared.loadNavigationState()
                    await MainActor.run {
                        selectedTab = state.selectedTab
                    }
                } catch {
                    print("Failed to load navigation state: \(error)")
                }
                await MainActor.run {
                    isNavigationRestoring = false
                }
            }
        }
        .tint(.pink)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("メインナビゲーション")
        .disabled(isNavigationRestoring)
        .overlay {
            if isNavigationRestoring {
                LoadingView(message: "復元中...")
                    .background(Color(UIColor.systemBackground))
            }
        }
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
                            .symbolEffect(.bounce, value: selectedTab)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.pink)
                            .symbolEffect(.bounce, value: selectedTab)
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
