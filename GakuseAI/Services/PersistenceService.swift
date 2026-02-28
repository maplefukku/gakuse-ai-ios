import Foundation

/// ローカルデータ永続化サービス
/// SOUL.mdのビジョン「人は入力しない」を実現 - 学習ログを自動保存
actor PersistenceService {
    static let shared = PersistenceService()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var appSupportURL: URL {
        fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
    
    private var learningLogsURL: URL {
        appSupportURL.appendingPathComponent("learning_logs.json")
    }
    
    private var userProfileURL: URL {
        appSupportURL.appendingPathComponent("user_profile.json")
    }
    
    private var chatHistoryURL: URL {
        appSupportURL.appendingPathComponent("chat_history.json")
    }
    
    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    private func ensureDirectoryExists() {
        try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
    }
    
    // MARK: - Learning Logs
    
    func saveLearningLogs(_ logs: [LearningLog]) async throws {
        ensureDirectoryExists()
        let data = try encoder.encode(logs)
        try data.write(to: learningLogsURL)
    }
    
    func loadLearningLogs() async throws -> [LearningLog] {
        ensureDirectoryExists()
        guard fileManager.fileExists(atPath: learningLogsURL.path) else {
            return []
        }
        let data = try Data(contentsOf: learningLogsURL)
        return try decoder.decode([LearningLog].self, from: data)
    }
    
    func appendLearningLog(_ log: LearningLog) async throws {
        var logs = try await loadLearningLogs()
        logs.append(log)
        try await saveLearningLogs(logs)
    }
    
    func deleteLearningLog(id: UUID) async throws {
        var logs = try await loadLearningLogs()
        logs.removeAll { $0.id == id }
        try await saveLearningLogs(logs)
    }
    
    func updateLearningLog(_ log: LearningLog) async throws {
        var logs = try await loadLearningLogs()
        if let index = logs.firstIndex(where: { $0.id == log.id }) {
            logs[index] = log
            try await saveLearningLogs(logs)
        }
    }
    
    // MARK: - User Profile
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        ensureDirectoryExists()
        let data = try encoder.encode(profile)
        try data.write(to: userProfileURL)
    }
    
    func loadUserProfile() async throws -> UserProfile? {
        ensureDirectoryExists()
        guard fileManager.fileExists(atPath: userProfileURL.path) else {
            return nil
        }
        let data = try Data(contentsOf: userProfileURL)
        return try decoder.decode(UserProfile.self, from: data)
    }
    
    // MARK: - Chat History
    
    func saveChatHistory(_ messages: [ChatMessageData]) async throws {
        ensureDirectoryExists()
        let data = try encoder.encode(messages)
        try data.write(to: chatHistoryURL)
    }
    
    func loadChatHistory() async throws -> [ChatMessageData] {
        ensureDirectoryExists()
        guard fileManager.fileExists(atPath: chatHistoryURL.path) else {
            return []
        }
        let data = try Data(contentsOf: chatHistoryURL)
        return try decoder.decode([ChatMessageData].self, from: data)
    }
    
    func appendChatMessage(_ message: ChatMessageData) async throws {
        var messages = try await loadChatHistory()
        messages.append(message)
        try await saveChatHistory(messages)
    }
    
    func clearChatHistory() async throws {
        try? fileManager.removeItem(at: chatHistoryURL)
    }
}

// MARK: - Supporting Models

struct UserProfile: Codable {
    let id: UUID
    var name: String
    var email: String?
    var avatarURL: URL?
    let createdAt: Date
    var settings: UserSettings
    
    init(name: String = "ユーザー") {
        self.id = UUID()
        self.name = name
        self.email = nil
        self.avatarURL = nil
        self.createdAt = Date()
        self.settings = UserSettings()
    }
}

struct UserSettings: Codable {
    var notificationsEnabled: Bool = true
    var theme: AppTheme = .system
    var autoSaveEnabled: Bool = true
}

enum AppTheme: String, Codable {
    case system
    case light
    case dark
}

struct ChatMessageData: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(content: String, isUser: Bool) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}
