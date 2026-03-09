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

// MARK: - Category Stat Row

struct CategoryStatRow: View {
    let item: CategoryDataPoint
    @State private var isPressed = false

    var body: some View {
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Stat Card

struct StatisticsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @State private var isPressed = false

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
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(skill.name): \(skill.count)回")
        .accessibilityValue("\(Int(skill.progress * 100))%")
    }
}

#Preview {
    StatisticsView()
}

// MARK: - Detail Popup Sheet

struct DetailPopupSheet: View {
    let dataPoint: WeeklyDataPoint
    let allLogs: [LearningLog]
    @Environment(\.locale) var locale
    @Environment(\.dismiss) var dismiss

    private var dayLogs: [LearningLog] {
        let calendar = Calendar.current
        return allLogs.filter { log in
            calendar.isDate(log.createdAt, inSameDayAs: dataPoint.date)
        }.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 日付と件数
                    VStack(alignment: .leading, spacing: 8) {
                        Text(formatDate(dataPoint.date))
                            .font(.title2.bold())
                        Text("\(dataPoint.weekday)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack(spacing: 8) {
                            Image(systemName: "doc.fill")
                            Text("\(dataPoint.count) 件の学習ログ")
                                .font(.headline)
                                .foregroundColor(.pink)
                        }
                    }
                    .padding(.vertical)

                    Divider()

                    // 学習ログリスト
                    if dayLogs.isEmpty {
                        Text("ログがありません")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(dayLogs) { log in
                                DayLogRow(log: log)
                                Divider()
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .accessibilityLabel("詳細を閉じる")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(formatDate(dataPoint.date))の学習ログ詳細")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = locale
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = locale
        return formatter.string(from: date)
    }
}

struct DayLogRow: View {
    let log: LearningLog
    @Environment(\.locale) var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // タイトルとカテゴリ
            HStack {
                Text(log.title)
                    .font(.headline)
                Spacer()
                Text(log.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(log.category.color.opacity(0.2))
                    .foregroundColor(log.category.color)
                    .cornerRadius(8)
            }

            // 説明
            Text(log.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // スキルとメタデータ
            HStack {
                if !log.skills.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text(log.skills.map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                    }
                }

                Spacer()

                Text(formatTime(log.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(log.title)、\(log.category.rawValue)")
        .accessibilityHint("学習ログの詳細")
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = locale
        return formatter.string(from: date)
    }
}
