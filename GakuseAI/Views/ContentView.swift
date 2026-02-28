import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            LearningLogView()
                .tabItem {
                    Label("学習ログ", systemImage: "book.fill")
                }
            
            PortfolioView()
                .tabItem {
                    Label("ポートフォリオ", systemImage: "person.fill")
                }
            
            AIChatView()
                .tabItem {
                    Label("AI壁打ち", systemImage: "bubble.left.and.bubble.right.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("プロフィール", systemImage: "gearshape.fill")
                }
        }
        .tint(.pink)
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
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.pink)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
