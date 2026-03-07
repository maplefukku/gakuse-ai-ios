import Foundation
import SwiftUI

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var learningLogs: [LearningLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userSettings: UserSettings = UserSettings()

    // 計算プロパティ
    var totalLogsCount: Int {
        learningLogs.count
    }

    var totalSkillsCount: Int {
        let allSkills = Set(learningLogs.flatMap { $0.skills.map { $0.name } })
        return allSkills.count
    }

    var streakDays: Int {
        calculateStreakDays()
    }

    var publicLogsCount: Int {
        learningLogs.filter { $0.isPublic }.count
    }

    var weeklyData: [WeeklyDataPoint] {
        calculateWeeklyData()
    }

    var categoryData: [CategoryDataPoint] {
        calculateCategoryData()
    }

    var topSkills: [SkillData] {
        calculateTopSkills()
    }

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
            learningLogs = try await persistenceService.loadLearningLogs()
            userSettings = try await persistenceService.loadUserSettings()
        } catch {
            errorMessage = "読み込みエラー: \(error.localizedDescription)"
        }
    }

    // MARK: - Calculation Methods

    private func calculateStreakDays() -> Int {
        guard !learningLogs.isEmpty else { return 0 }

        let calendar = Calendar.current
        let sortedLogs = learningLogs.sorted { $0.createdAt > $1.createdAt }

        var datesWithLogs: Set<Date> = []
        for log in sortedLogs {
            if let date = calendar.dateComponents([.year, .month, .day], from: log.createdAt).date {
                datesWithLogs.insert(date)
            }
        }

        guard let today = calendar.dateComponents([.year, .month, .day], from: Date()).date else {
            return 0
        }

        var currentDate = datesWithLogs.contains(today) ? today : datesWithLogs.max()
        var streak = 0

        while let date = currentDate, datesWithLogs.contains(date) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: date)
        }

        return streak
    }

    private func calculateWeeklyData() -> [WeeklyDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = userSettings.language.locale
        dateFormatter.dateFormat = "E"

        var dataPoints: [WeeklyDataPoint] = []

        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }

            let count = learningLogs.filter { log in
                calendar.isDate(log.createdAt, inSameDayAs: targetDate)
            }.count

            let weekday = dateFormatter.string(from: targetDate)
            dataPoints.append(WeeklyDataPoint(date: targetDate, count: count, weekday: weekday))
        }

        return dataPoints.sorted { $0.date < $1.date }
    }

    private func calculateCategoryData() -> [CategoryDataPoint] {
        let grouped = Dictionary(grouping: learningLogs, by: { $0.category })

        return LearningCategory.allCases.compactMap { category in
            let count = grouped[category]?.count ?? 0
            if count > 0 {
                let color: Color = {
                    switch category {
                    case .programming: return .blue
                    case .design: return .purple
                    case .business: return .orange
                    case .language: return .green
                    case .creative: return .pink
                    case .other: return .gray
                    }
                }()
                return CategoryDataPoint(category: category, count: count, color: color)
            }
            return nil
        }
    }

    private func calculateTopSkills() -> [SkillData] {
        let skillCounts = Dictionary(grouping: learningLogs.flatMap { $0.skills }, by: { $0.name })
            .mapValues { $0.count }

        let maxCount = skillCounts.values.max() ?? 1

        return skillCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { name, count in
                SkillData(
                    name: name,
                    count: count,
                    progress: Double(count) / Double(maxCount)
                )
            }
    }
}

// MARK: - Data Models

struct WeeklyDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let weekday: String
}

struct CategoryDataPoint: Identifiable {
    let id = UUID()
    let category: LearningCategory
    let count: Int
    let color: Color
}

struct SkillData: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let progress: Double
}
