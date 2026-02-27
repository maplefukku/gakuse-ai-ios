import SwiftUI

struct PortfolioView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 12) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 100, height: 100)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                        
                        Text("あなたのポートフォリオ")
                            .font(.title2.bold())
                        
                        Text("学習ログを公開して、ポートフォリオを充実させましょう")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Stats
                    HStack(spacing: 20) {
                        StatCard(title: "学習ログ", value: "0", icon: "book.fill")
                        StatCard(title: "スキル", value: "0", icon: "star.fill")
                        StatCard(title: "継続日数", value: "0", icon: "flame.fill")
                    }
                    .padding(.horizontal)
                    
                    // Public Logs
                    VStack(alignment: .leading, spacing: 12) {
                        Text("公開中のログ")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ContentUnavailableView(
                            "まだ公開ログがありません",
                            systemImage: "doc.text",
                            description: Text("学習ログを公開するとここに表示されます")
                        )
                        .frame(height: 200)
                    }
                }
            }
            .navigationTitle("ポートフォリオ")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.pink)
            
            Text(value)
                .font(.title.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    PortfolioView()
}
