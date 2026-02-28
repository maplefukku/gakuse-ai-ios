import Foundation
import SwiftUI

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
            
            // スキル数をカウント
            totalSkills = allLogs.reduce(0) { $0 + $1.skills.count }
            
            // 継続日数を計算（簡易版：最後のログからの日数）
            if let lastLog = allLogs.sorted(by: { $0.createdAt > $1.createdAt }).first {
                let calendar = Calendar.current
                let days = calendar.dateComponents([.day], from: lastLog.createdAt, to: Date()).day ?? 0
                streakDays = max(0, days)
            }
        } catch {
            print("読み込みエラー: \(error)")
        }
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
}
