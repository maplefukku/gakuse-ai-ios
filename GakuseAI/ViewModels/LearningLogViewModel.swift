import Foundation
import SwiftUI

@MainActor
class LearningLogViewModel: ObservableObject {
    @Published var logs: [LearningLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateSheet = false
    
    private let persistenceService = PersistenceService.shared
    
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
        } catch {
            errorMessage = "保存エラー: \(error.localizedDescription)"
        }
    }
    
    func deleteLog(at offsets: IndexSet) async {
        for index in offsets {
            do {
                try await persistenceService.deleteLearningLog(id: logs[index].id)
            } catch {
                errorMessage = "削除エラー: \(error.localizedDescription)"
            }
        }
        logs.remove(atOffsets: offsets)
    }
    
    func togglePublic(for log: LearningLog) async {
        var updatedLog = log
        updatedLog.isPublic.toggle()
        await updateLog(updatedLog)
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
    
    func getLog(by id: UUID) -> Binding<LearningLog>? {
        guard let index = logs.firstIndex(where: { $0.id == id }) else { return nil }
        return Binding(
            get: { self.logs[index] },
            set: { self.logs[index] = $0 }
        )
    }
}
