import Foundation

actor APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api.gakuse.ai" // TODO: Configure actual API URL
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    func fetchLearningLogs() async throws -> [LearningLog] {
        // TODO: Implement actual API call
        // For now, return sample data
        return [
            LearningLog(
                title: "SwiftUI学習開始",
                description: "SwiftUIの基本概念を学んだ。View、State、Bindingの理解。",
                category: .programming,
                isPublic: true
            ),
            LearningLog(
                title: "FigmaでUIデザイン",
                description: "モバイルアプリのUI設計を練習。コンポーネント設計のコツを掴んだ。",
                category: .design,
                isPublic: false
            )
        ]
    }
    
    func createLearningLog(_ log: LearningLog) async throws -> LearningLog {
        // TODO: Implement actual API call
        return log
    }
}
