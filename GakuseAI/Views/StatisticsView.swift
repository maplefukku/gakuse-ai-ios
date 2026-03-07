import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("統計データを読み込み中...")
                } else if viewModel.learningLogs.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // 概要セクション
                            overviewSection

                            // 学習傾向セクション
                            trendSection

                            // カテゴリ分析セクション
                            categoryAnalysisSection

                            // スキル分析セクション
                            skillAnalysisSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.loadData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ContentUnavailableView(
            "データがありません",
            systemImage: "chart.bar",
            description: Text("学習ログを作成すると統計が表示されます")
        )
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("概要")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatisticsStatCard(
                    title: "総ログ数",
                    value: "\(viewModel.totalLogsCount)",
                    icon: "book.fill",
                    color: .pink
                )

                StatisticsStatCard(
                    title: "総スキル数",
                    value: "\(viewModel.totalSkillsCount)",
                    icon: "star.fill",
                    color: .orange
                )

                StatisticsStatCard(
                    title: "継続日数",
                    value: "\(viewModel.streakDays)日",
                    icon: "flame.fill",
                    color: .red
                )

                StatisticsStatCard(
                    title: "公開ログ",
                    value: "\(viewModel.publicLogsCount)",
                    icon: "globe",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Trend Section

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("学習傾向")
                .font(.headline)

            Chart(viewModel.weeklyData, id: \.date) { item in
                BarMark(
                    x: .value("曜日", item.weekday),
                    y: .value("ログ数", item.count)
                )
                .foregroundStyle(.pink)
                .cornerRadius(4)
            }
            .frame(height: 200)
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
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Category Analysis Section

    private var categoryAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("カテゴリ分析")
                .font(.headline)

            Chart(viewModel.categoryData, id: \.category) { item in
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
                    Text("総ログ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // カテゴリ一覧
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.categoryData, id: \.category) { item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)

                        Text(item.category.rawValue)
                            .font(.subheadline)

                        Spacer()

                        Text("\(item.count)")
                            .font(.headline)
                            .foregroundColor(.pink)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Skill Analysis Section

    private var skillAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("スキル分析")
                .font(.headline)

            if viewModel.topSkills.isEmpty {
                Text("スキルが登録されていません")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.topSkills, id: \.name) { skill in
                        SkillProgressRow(skill: skill)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Stat Card

struct StatisticsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Skill Progress Row

struct SkillProgressRow: View {
    let skill: SkillData

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(skill.name)
                    .font(.subheadline)

                Spacer()

                Text("\(skill.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: skill.progress)
                .tint(.pink)
        }
    }
}

#Preview {
    StatisticsView()
}
