import SwiftUI
import Charts

struct PortfolioView: View {
    @StateObject private var viewModel = PortfolioViewModel()
    @State private var showingStatistics = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader

                    // Stats
                    statsSection

                    // Weekly Chart
                    if !viewModel.weeklyData.filter({ $0.count > 0 }).isEmpty {
                        weeklyChartSection
                    }

                    // Category Chart
                    if !viewModel.categoryChartData.isEmpty {
                        categoryChartSection
                    }

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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingStatistics = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                }
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView()
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
    
    // MARK: - Weekly Chart Section

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間学習ログ")
                .font(.headline)
            
            Chart(viewModel.weeklyData, id: \.weekday) { item in
                BarMark(
                    x: .value("曜日", item.weekday),
                    y: .value("数", item.count)
                )
                .foregroundStyle(.pink)
                .cornerRadius(4)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel {
                        if let stringValue = value.as(String.self) {
                            Text(stringValue)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Category Chart

    private var categoryChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリ別分布")
                .font(.headline)
            
            Chart(viewModel.categoryChartData, id: \.category) { item in
                SectorMark(
                    angle: .value("数", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
            }
            .frame(height: 200)
            .chartBackground { _ in
                VStack {
                    Text("\(viewModel.totalLogsCount)")
                        .font(.largeTitle.bold())
                    Text("ログ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カテゴリ詳細")
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
