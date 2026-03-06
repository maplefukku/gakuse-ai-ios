import Foundation
import SwiftUI
import Charts

@MainActor
class PortfolioViewModel: ObservableObject {
    @Published var publicLogs: [LearningLog] = []
    @Published var totalSkills: Int = 0
    @Published var streakDays: Int = 0
    @Published var isLoading = false
    
    private let persistenceService = PersistenceService.shared
    
    init() {
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allLogs = try await persistenceService.loadLearningLogs()
            publicLogs = allLogs.filter { $0.isPublic }

            // スキル数をカウント（重複除外）
            let allSkills = Set(allLogs.flatMap { $0.skills.map { $0.name } })
            totalSkills = allSkills.count

            // 継続日数を計算（連続学習日数）
            streakDays = calculateStreakDays(from: allLogs)
        } catch {
            print("読み込みエラー: \(error)")
        }
    }

    /// 連続学習日数を計算する
    private func calculateStreakDays(from logs: [LearningLog]) -> Int {
        guard !logs.isEmpty else { return 0 }

        let calendar = Calendar.current
        let sortedLogs = logs.sorted { $0.createdAt > $1.createdAt }

        // 日付ごとにグループ化（ローカルタイムゾーンで日付を取得）
        var datesWithLogs: Set<Date> = []
        for log in sortedLogs {
            if let date = calendar.dateComponents([.year, .month, .day], from: log.createdAt).date {
                datesWithLogs.insert(date)
            }
        }

        guard let today = calendar.dateComponents([.year, .month, .day], from: Date()).date else {
            return 0
        }

        // 今日がログの一部でない場合、最新のログの日からカウント開始
        var currentDate = datesWithLogs.contains(today) ? today : datesWithLogs.max()
        var streak = 0

        while let date = currentDate, datesWithLogs.contains(date) {
            streak += 1
            // 前日に戻る
            currentDate = calendar.date(byAdding: .day, value: -1, to: date)
        }

        return streak
    }
    
    var totalLogsCount: Int {
        publicLogs.count
    }
    
    var categoriesWithCount: [(LearningCategory, Int)] {
        let grouped = Dictionary(grouping: publicLogs, by: { $0.category })
        return LearningCategory.allCases.compactMap { category in
            let count = grouped[category]?.count ?? 0
            return count > 0 ? (category, count) : nil
        }
    }

    /// カテゴリ別のデータをチャート用に変換
    var categoryChartData: [(category: LearningCategory, count: Int, color: Color)] {
        let grouped = Dictionary(grouping: publicLogs, by: { $0.category })
        return LearningCategory.allCases.compactMap { category in
            let count = grouped[category]?.count ?? 0
            if count > 0 {
                return (category: category, count: count, color: categoryColor(for: category))
            }
            return nil
        }
    }

    /// カテゴリの色を取得
    private func categoryColor(for category: LearningCategory) -> Color {
        switch category {
        case .programming: return .blue
        case .design: return .purple
        case .business: return .orange
        case .language: return .green
        case .creative: return .pink
        case .other: return .gray
        }
    }

    /// 週間の学習ログ数を取得
    var weeklyData: [(weekday: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()

        var dailyCounts: [String: Int] = [:]
        let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

        // 過去7日間の曜日ごとのログをカウント
        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: today),
                  let weekday = calendar.dateComponents([.weekday], from: targetDate).weekday else {
                continue
            }

            let weekdayName = weekdays[weekday - 1]

            // その曜日のログをカウント
            let count = publicLogs.filter { log in
                calendar.isDate(log.createdAt, inSameDayAs: targetDate)
            }.count

            dailyCounts[weekdayName] = count
        }

        return weekdays.map { weekday in
            (weekday: weekday, count: dailyCounts[weekday] ?? 0)
        }
    }
}
