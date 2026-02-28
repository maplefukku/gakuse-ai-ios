import SwiftUI

struct PortfolioView: View {
    @StateObject private var viewModel = PortfolioViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader
                    
                    // Stats
                    statsSection
                    
                    // Category Breakdown
                    if !viewModel.categoriesWithCount.isEmpty {
                        categoryBreakdown
                    }
                    
                    // Public Logs
                    publicLogsSection
                }
                .padding()
            }
            .navigationTitle("ポートフォリオ")
            .refreshable {
                await viewModel.loadData()
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
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
                .shadow(color: .pink.opacity(0.3), radius: 10)
            
            Text("あなたのポートフォリオ")
                .font(.title2.bold())
            
            Text("学習ログを公開して、ポートフォリオを充実させましょう")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "学習ログ",
                value: "\(viewModel.totalLogsCount)",
                icon: "book.fill",
                color: .pink
            )
            
            StatCard(
                title: "スキル",
                value: "\(viewModel.totalSkills)",
                icon: "star.fill",
                color: .yellow
            )
            
            StatCard(
                title: "継続日数",
                value: "\(viewModel.streakDays)",
                icon: "flame.fill",
                color: .orange
            )
        }
    }
    
    // MARK: - Category Breakdown
    
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリ別")
                .font(.headline)
            
            ForEach(viewModel.categoriesWithCount, id: \.0) { category, count in
                HStack {
                    Image(systemName: category.icon)
                        .foregroundColor(.pink)
                        .frame(width: 24)
                    
                    Text(category.rawValue)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.headline)
                        .foregroundColor(.pink)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Public Logs Section
    
    private var publicLogsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("公開中のログ")
                    .font(.headline)
                
                Spacer()
                
                if !viewModel.publicLogs.isEmpty {
                    Text("\(viewModel.publicLogs.count)件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if viewModel.publicLogs.isEmpty {
                ContentUnavailableView(
                    "まだ公開ログがありません",
                    systemImage: "doc.text",
                    description: Text("学習ログを公開するとここに表示されます")
                )
                .frame(height: 200)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.publicLogs) { log in
                        PortfolioLogCard(log: log)
                    }
                }
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Portfolio Log Card

struct PortfolioLogCard: View {
    let log: LearningLog
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: log.category.icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.pink)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(log.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(log.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    PortfolioView()
}
