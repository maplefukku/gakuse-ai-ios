import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
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
    }
}

#Preview {
    ContentView()
}
