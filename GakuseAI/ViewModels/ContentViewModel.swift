import Foundation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    @Published var learningLogs: [LearningLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadLearningLogs() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            learningLogs = try await apiService.fetchLearningLogs()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func createLearningLog(_ log: LearningLog) async {
        do {
            let newLog = try await apiService.createLearningLog(log)
            learningLogs.append(newLog)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
