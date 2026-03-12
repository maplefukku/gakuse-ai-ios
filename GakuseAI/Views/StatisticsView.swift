import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var selectedDataPoint: WeeklyDataPoint?
    @State private var showingDetailPopup = false

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("統計データを読み込み中...")
                        .accessibilityLabel("統計データを読み込み中")
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
                    .accessibilityLabel("統計を更新")
                    .accessibilityHint("最新の学習データを再取得します")
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("統計画面")
        .sheet(isPresented: $showingDetailPopup) {
            if let dataPoint = selectedDataPoint {
                DetailPopupSheet(dataPoint: dataPoint, allLogs: viewModel.learningLogs)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .drawingGroup() // パフォーマンス最適化: レイヤー合成をまとめる
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
                .opacity(selectedDataPoint?.date == item.date ? 1.0 : 0.7)
                .annotation(position: .top) {
                    if item.count > 0 {
                        Text("\(item.count)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
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
            .drawingGroup() // パフォーマンス改善: レイヤー合成を最適化
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            SimultaneousGesture(
                                // タップ（短押し）で選択
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let x = value.location.x - geometry[proxy.plotFrame!].minX
                                        if let date: Date = proxy.value(atX: x) {
                                            selectedDataPoint = viewModel.weeklyData.first { $0.date == date }
                                        }
                                    },
                                // 長押しで詳細ポップアップ表示
                                LongPressGesture(minimumDuration: 0.5)
                                    .onEnded { _ in
                                        if selectedDataPoint != nil {
                                            showingDetailPopup = true
                                        }
                                    }
                            )
                        )
                }
            }

            if let selectedDataPoint = selectedDataPoint {
                HStack {
                    Text("選択: \(selectedDataPoint.weekday)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(selectedDataPoint.count) 件")
                        .font(.caption.bold())
                        .foregroundColor(.pink)
                }
                .padding(.top, 4)
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
            .drawingGroup() // パフォーマンス改善: レイヤー合成を最適化
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
                    CategoryStatRow(item: item)
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

#Preview {
    StatisticsView()
}
