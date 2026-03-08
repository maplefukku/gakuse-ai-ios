import Foundation
import SwiftUI

/// ログのソート基準
enum LogSortOrder: String, CaseIterable {
    case newestFirst = "新しい順"
    case oldestFirst = "古い順"
    case titleAscending = "タイトル順（A-Z）"
    case titleDescending = "タイトル順（Z-A）"
    case category = "カテゴリ順"
}

@MainActor
class LearningLogViewModel: ObservableObject {
    @Published var logs: [LearningLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateSheet = false
    @Published var searchText = ""
    @Published var selectedCategory: LearningCategory? = nil
    @Published var showOnlyPublic = false
    @Published var logToEdit: LearningLog? = nil
    @Published var sortOrder: LogSortOrder = .newestFirst
    @Published var showingFavoritesOnly = false
    @Published var showingExportOptions = false
    @Published var showingSearchOptions = false
    @Published var dateRangeStart: Date? = nil
    @Published var dateRangeEnd: Date? = nil
    @Published var searchInSkills = false
    
    private let persistenceService = PersistenceService.shared

    /// フィルター適用後のログリスト
    var filteredLogs: [LearningLog] {
        var result = logs

        // テキスト検索
        if !searchText.isEmpty {
            result = result.filter { log in
                log.title.localizedCaseInsensitiveContains(searchText) ||
                log.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        // カテゴリフィルター
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // 公開設定フィルター
        if showOnlyPublic {
            result = result.filter { $0.isPublic }
        }

        // お気に入りフィルター
        if showingFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        // 日付範囲フィルター
        if let startDate = dateRangeStart {
            result = result.filter { $0.createdAt >= startDate }
        }
        if let endDate = dateRangeEnd {
            result = result.filter { $0.createdAt <= endDate }
        }

        // スキル検索
        if searchInSkills, !searchText.isEmpty {
            result = result.filter { log in
                log.skills.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }

        // ソート
        result = sortLogs(result, by: sortOrder)

        return result
    }

    /// お気に入りのログ数
    var favoriteCount: Int {
        logs.filter { $0.isFavorite }.count
    }

    /// ログのソート
    private func sortLogs(_ logs: [LearningLog], by order: LogSortOrder) -> [LearningLog] {
        return logs.sorted { log1, log2 in
            switch order {
            case .newestFirst:
                return log1.createdAt > log2.createdAt
            case .oldestFirst:
                return log1.createdAt < log2.createdAt
            case .titleAscending:
                return log1.title.localizedCompare(log2.title) == .orderedAscending
            case .titleDescending:
                return log1.title.localizedCompare(log2.title) == .orderedDescending
            case .category:
                return log1.category.rawValue.localizedCompare(log2.category.rawValue) == .orderedAscending
            }
        }
    }
    
    init() {
        Task {
            await loadLogs()
        }
    }
    
    func loadLogs() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            logs = try await persistenceService.loadLearningLogs()
            // 新しい順にソート
            logs.sort { $0.createdAt > $1.createdAt }
        } catch {
            errorMessage = "読み込みエラー: \(error.localizedDescription)"
        }
    }
    
    func createLog(title: String, description: String, category: LearningCategory, isPublic: Bool) async {
        let newLog = LearningLog(
            title: title,
            description: description,
            category: category,
            isPublic: isPublic
        )
        
        do {
            try await persistenceService.appendLearningLog(newLog)
            logs.insert(newLog, at: 0) // 先頭に追加
            HapticFeedback.success() // ログ作成成功
        } catch {
            errorMessage = "保存エラー: \(error.localizedDescription)"
            HapticFeedback.error() // エラー時
        }
    }
    
    func deleteLog(at offsets: IndexSet) async {
        for index in offsets {
            do {
                try await persistenceService.deleteLearningLog(id: logs[index].id)
            } catch {
                errorMessage = "削除エラー: \(error.localizedDescription)"
                HapticFeedback.error() // エラー時
                return
            }
        }
        HapticFeedback.heavy() // 削除成功
        logs.remove(atOffsets: offsets)
    }
    
    func deleteLog(_ log: LearningLog) async {
        do {
            try await persistenceService.deleteLearningLog(id: log.id)
            logs.removeAll { $0.id == log.id }
        } catch {
            errorMessage = "削除エラー: \(error.localizedDescription)"
        }
    }
    
    func togglePublic(for log: LearningLog) async {
        var updatedLog = log
        updatedLog.isPublic.toggle()
        await updateLog(updatedLog)
        HapticFeedback.light() // 公開設定切替
    }

    func toggleFavorite(for log: LearningLog) async {
        var updatedLog = log
        updatedLog.isFavorite.toggle()
        await updateLog(updatedLog)
        HapticFeedback.success() // お気に入り切替
    }
    
    func addSkill(to log: LearningLog, name: String, level: SkillLevel) async {
        var updatedLog = log
        updatedLog.skills.append(Skill(name: name, level: level))
        await updateLog(updatedLog)
    }
    
    func addReflection(to log: LearningLog, content: String, type: ReflectionType) async {
        var updatedLog = log
        updatedLog.reflections.append(Reflection(content: content, type: type))
        await updateLog(updatedLog)
    }
    
    func removeSkill(at offsets: IndexSet, from log: LearningLog) async {
        var updatedLog = log
        updatedLog.skills.remove(atOffsets: offsets)
        await updateLog(updatedLog)
    }

    func removeReflection(at offsets: IndexSet, from log: LearningLog) async {
        var updatedLog = log
        updatedLog.reflections.remove(atOffsets: offsets)
        await updateLog(updatedLog)
    }
    
    private func updateLog(_ log: LearningLog) async {
        do {
            try await persistenceService.updateLearningLog(log)
            if let index = logs.firstIndex(where: { $0.id == log.id }) {
                logs[index] = log
            }
        } catch {
            errorMessage = "更新エラー: \(error.localizedDescription)"
        }
    }
    
    /// ログの基本情報を更新
    func updateLog(id: UUID, title: String, description: String, category: LearningCategory, isPublic: Bool) async {
        guard let index = logs.firstIndex(where: { $0.id == id }) else {
            errorMessage = "ログが見つかりません"
            return
        }

        var updatedLog = logs[index]
        // 新しいLearningLogを作成して値を更新
        updatedLog = LearningLog(
            id: updatedLog.id,
            title: title,
            description: description,
            category: category,
            isPublic: isPublic,
            createdAt: updatedLog.createdAt,
            updatedAt: Date(),
            skills: updatedLog.skills,
            reflections: updatedLog.reflections,
            isFavorite: updatedLog.isFavorite
        )

        await updateLog(updatedLog)
    }
    
    /// 編集モードを開始
    func editLog(_ log: LearningLog) {
        logToEdit = log
    }
    
    func getLog(by id: UUID) -> Binding<LearningLog>? {
        guard let index = logs.firstIndex(where: { $0.id == id }) else { return nil }
        return Binding(
            get: { self.logs[index] },
            set: { self.logs[index] = $0 }
        )
    }

    // MARK: - Export Functions

    /// CSV形式でエクスポート
    func exportToCSV() -> URL? {
        let fileName = "learning_logs_\(Date().timeIntervalSince1970).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        var csvContent = "タイトル,説明,カテゴリ,作成日時,公開設定,スキル,振り返り\n"

        for log in filteredLogs {
            let title = escapeCSV(log.title)
            let description = escapeCSV(log.description)
            let category = escapeCSV(log.category.rawValue)
            let createdAt = formatDate(log.createdAt)
            let isPublic = log.isPublic ? "公開" : "非公開"
            let skills = log.skills.map { $0.name }.joined(separator: ";")
            let reflections = log.reflections.map { $0.content }.joined(separator: ";")

            csvContent += "\(title),\(description),\(category),\(createdAt),\(isPublic),\(skills),\(reflections)\n"
        }

        do {
            try csvContent.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            errorMessage = "エクスポートエラー: \(error.localizedDescription)"
            return nil
        }
    }

    /// JSON形式でエクスポート
    func exportToJSON() -> URL? {
        let fileName = "learning_logs_\(Date().timeIntervalSince1970).json"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            let data = try JSONEncoder().encode(filteredLogs)
            try data.write(to: path)
            return path
        } catch {
            errorMessage = "エクスポートエラー: \(error.localizedDescription)"
            return nil
        }
    }

    /// 検索オプションをリセット
    func resetSearchOptions() {
        searchText = ""
        selectedCategory = nil
        showOnlyPublic = false
        showingFavoritesOnly = false
        dateRangeStart = nil
        dateRangeEnd = nil
        searchInSkills = false
        sortOrder = .newestFirst
    }

    // MARK: - Helper Methods

    private func escapeCSV(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
