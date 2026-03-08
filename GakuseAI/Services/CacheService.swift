import Foundation

/// レスポンスキャッシュサービス（オフライン対応）
/// SOUL.mdのビジョン「学習ログを資産化」を実現 - オフラインでも学習可能
actor CacheService {
    static let shared = CacheService()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let cacheDuration: TimeInterval = 60 * 60 * 24 // 24時間
    
    private var cacheURL: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Cache Entry
    
    private struct CacheEntry<T: Codable>: Codable {
        let data: T
        let timestamp: Date
        let cacheDuration: TimeInterval
        
        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > cacheDuration
        }
        
        init(data: T, timestamp: Date, cacheDuration: TimeInterval) {
            self.data = data
            self.timestamp = timestamp
            self.cacheDuration = cacheDuration
        }
    }
    
    // MARK: - Learning Logs Cache
    
    private var learningLogsCacheURL: URL {
        cacheURL.appendingPathComponent("learning_logs_cache.json")
    }
    
    func getCachedLearningLogs() async throws -> [LearningLog]? {
        guard fileManager.fileExists(atPath: learningLogsCacheURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: learningLogsCacheURL)
        let entry = try decoder.decode(CacheEntry<[LearningLog]>.self, from: data)
        
        guard !entry.isExpired else {
            try? fileManager.removeItem(at: learningLogsCacheURL)
            return nil
        }
        
        return entry.data
    }
    
    func cacheLearningLogs(_ logs: [LearningLog]) async throws {
        let entry = CacheEntry(data: logs, timestamp: Date(), cacheDuration: cacheDuration)
        let data = try encoder.encode(entry)
        try data.write(to: learningLogsCacheURL)
    }
    
    // MARK: - Chat History Cache
    
    private var chatHistoryCacheURL: URL {
        cacheURL.appendingPathComponent("chat_history_cache.json")
    }
    
    func getCachedChatHistory() async throws -> [ChatMessageData]? {
        guard fileManager.fileExists(atPath: chatHistoryCacheURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: chatHistoryCacheURL)
        let entry = try decoder.decode(CacheEntry<[ChatMessageData]>.self, from: data)
        
        guard !entry.isExpired else {
            try? fileManager.removeItem(at: chatHistoryCacheURL)
            return nil
        }
        
        return entry.data
    }
    
    func cacheChatHistory(_ messages: [ChatMessageData]) async throws {
        let entry = CacheEntry(data: messages, timestamp: Date(), cacheDuration: cacheDuration)
        let data = try encoder.encode(entry)
        try data.write(to: chatHistoryCacheURL)
    }
    
    // MARK: - Generic Cache
    
    func cache<T: Codable>(_ data: T, forKey key: String) async throws {
        let entry = CacheEntry(data: data, timestamp: Date(), cacheDuration: cacheDuration)
        let url = cacheURL.appendingPathComponent("\(key)_cache.json")
        let encodedData = try encoder.encode(entry)
        try encodedData.write(to: url)
    }
    
    func getCached<T: Codable>(forKey key: String, type: T.Type) async throws -> T? {
        let url = cacheURL.appendingPathComponent("\(key)_cache.json")
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: url)
        let entry = try decoder.decode(CacheEntry<T>.self, from: data)
        
        guard !entry.isExpired else {
            try? fileManager.removeItem(at: url)
            return nil
        }
        
        return entry.data
    }
    
    // MARK: - Cache Management
    
    func clearCache() async throws {
        let cacheURLs = try? fileManager.contentsOfDirectory(
            at: cacheURL,
            includingPropertiesForKeys: nil
        )
        
        for url in cacheURLs ?? [] {
            try? fileManager.removeItem(at: url)
        }
    }
    
    func clearExpiredCache() async throws {
        let cacheURLs = try? fileManager.contentsOfDirectory(
            at: cacheURL,
            includingPropertiesForKeys: nil
        )
        
        for url in cacheURLs ?? [] {
            let data = try Data(contentsOf: url)
            
            // LearningLogsまたはChatHistoryのキャッシュのみチェック
            if url.lastPathComponent.contains("learning_logs_cache") {
                let entry = try decoder.decode(CacheEntry<[LearningLog]>.self, from: data)
                if entry.isExpired {
                    try? fileManager.removeItem(at: url)
                }
            } else if url.lastPathComponent.contains("chat_history_cache") {
                let entry = try decoder.decode(CacheEntry<[ChatMessageData]>.self, from: data)
                if entry.isExpired {
                    try? fileManager.removeItem(at: url)
                }
            }
        }
    }
    
    func getCacheSize() async -> Int64 {
        var totalSize: Int64 = 0
        let cacheURLs = try? fileManager.contentsOfDirectory(
            at: cacheURL,
            includingPropertiesForKeys: [.fileSizeKey]
        )
        
        for url in cacheURLs ?? [] {
            if let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
}
