import Foundation

/// データ同期サービス
/// SOUL.mdのビジョン「学習ログを資産化」を実現 - バックエンドとローカルデータの同期
actor SyncService {
    static let shared = SyncService()

    private let api = APIService.shared
    private let persistence = PersistenceService.shared
    private let cache = CacheService.shared

    private var isSyncing = false
    private var lastSyncTime: Date?

    private init() {
        // 最後の同期時間を読み込み
        Task {
            await loadLastSyncTime()
        }
    }

    // MARK: - Sync State

    var syncInProgress: Bool {
        isSyncing
    }

    var lastSyncDate: Date? {
        lastSyncTime
    }

    // MARK: - Full Sync

    /// 全データをバックエンドと同期
    func syncAllData() async throws -> SyncResult {
        guard !isSyncing else {
            throw SyncError.syncInProgress
        }

        isSyncing = true
        defer { isSyncing = false }

        var result = SyncResult(
            syncedLogs: 0,
            failedLogs: 0,
            syncDuration: 0,
            syncedAt: Date()
        )

        let startTime = Date()

        do {
            // 1. 学習ログを同期
            let logsResult = try await syncLearningLogs()
            result.syncedLogs = logsResult.synced
            result.failedLogs = logsResult.failed

            // 2. チャット履歴を同期
            try await syncChatHistory()

            // 3. ユーザープロフィールを同期
            try await syncUserProfile()

            // 同期時間を保存
            lastSyncTime = Date()
            try await saveLastSyncTime()

        } catch {
            result.error = error
            throw error
        }

        result.syncDuration = Date().timeIntervalSince(startTime)
        return result
    }

    // MARK: - Learning Logs Sync

    /// 学習ログをバックエンドと同期
    func syncLearningLogs() async throws -> SyncItemResult {
        // ローカルの学習ログを取得
        let localLogs = try await persistence.loadLearningLogs()

        // バックエンドの学習ログを取得（オフラインの場合はキャッシュを使用）
        let remoteLogs: [LearningLog]
        if api.isConnected {
            remoteLogs = try await api.fetchLearningLogs()
        } else {
            remoteLogs = (try await cache.getCachedLearningLogs()) ?? []
        }

        var synced = 0
        var failed = 0

        // マージ戦略:
        // 1. バックエンドにのみ存在するログはローカルに追加
        // 2. ローカルにのみ存在するログはバックエンドに追加
        // 3. 両方に存在するログは、更新日時が新しい方を採用

        let remoteLogIDs = Set(remoteLogs.map { $0.id })
        let localLogIDs = Set(localLogs.map { $0.id })

        // バックエンドにのみ存在するログをローカルに追加
        for remoteLog in remoteLogs {
            if !localLogIDs.contains(remoteLog.id) {
                do {
                    try await persistence.appendLearningLog(remoteLog)
                    synced += 1
                } catch {
                    failed += 1
                }
            }
        }

        // ローカルにのみ存在するログをバックエンドに追加
        for localLog in localLogs {
            if !remoteLogIDs.contains(localLog.id) {
                if api.isConnected {
                    do {
                        _ = try await api.createLearningLog(localLog)
                        synced += 1
                    } catch {
                        failed += 1
                    }
                } else {
                    // オフラインの場合は失敗とみなす
                    failed += 1
                }
            }
        }

        // 両方に存在するログのマージ
        for localLog in localLogs {
            if let remoteLog = remoteLogs.first(where: { $0.id == localLog.id }) {
                // 更新日時が新しい方を採用
                let isNewerLocal = localLog.updatedAt > remoteLog.updatedAt

                if isNewerLocal && api.isConnected {
                    // ローカルの方が新しいので、バックエンドを更新
                    do {
                        _ = try await api.updateLearningLog(localLog)
                        synced += 1
                    } catch {
                        failed += 1
                    }
                } else if !isNewerLocal {
                    // バックエンドの方が新しいので、ローカルを更新
                    do {
                        try await persistence.updateLearningLog(remoteLog)
                        synced += 1
                    } catch {
                        failed += 1
                    }
                }
            }
        }

        // キャッシュを更新
        try? await cache.cacheLearningLogs(try await persistence.loadLearningLogs())

        return SyncItemResult(synced: synced, failed: failed)
    }

    // MARK: - Chat History Sync

    /// チャット履歴をバックエンドと同期
    func syncChatHistory() async throws {
        // チャット履歴はローカルのみで管理するため、バックエンドとの同期は実装しない
        // 将来的にチャット履歴をクラウドに保存する場合は、ここに実装を追加

        // キャッシュを更新
        let chatHistory = try await persistence.loadChatHistory()
        try? await cache.cacheChatHistory(chatHistory)
    }

    // MARK: - User Profile Sync

    /// ユーザープロフィールをバックエンドと同期
    func syncUserProfile() async throws {
        // ユーザープロフィールはSupabase Authで管理しているため、バックエンドとの同期は不要
        // 将来的にプロフィールをバックエンドAPIで管理する場合は、ここに実装を追加

        // ローカルのプロフィールを取得
        let profile = try await persistence.loadUserProfile()

        // プロフィールが存在しない場合は初期値を作成
        if profile == nil {
            let newProfile = UserProfile()
            try await persistence.saveUserProfile(newProfile)
        }
    }

    // MARK: - Incremental Sync

    /// 増分同期（最後の同期以降に変更されたデータのみ同期）
    func syncIncremental() async throws -> SyncResult {
        guard let lastSync = lastSyncTime else {
            // 初回同期はフル同期を実行
            return try await syncAllData()
        }

        // 増分同期の実装
        // 現在はフル同期と同じ処理を実行
        return try await syncAllData()
    }

    // MARK: - Conflict Resolution

    /// 同期コンフリクトの解決
    /// - Parameters:
    ///   - local: ローカルのデータ
    ///   - remote: バックエンドのデータ
    /// - Returns: 採用するデータ
    func resolveConflict<T: Syncable>(local: T, remote: T) async throws -> T {
        // 更新日時が新しい方を採用
        return local.updatedAt > remote.updatedAt ? local : remote
    }

    // MARK: - Sync State Persistence

    private func saveLastSyncTime() async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(lastSyncTime ?? Date())

        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let lastSyncURL = cacheURL.appendingPathComponent("last_sync_time.json")
        try data.write(to: lastSyncURL)
    }

    private func loadLastSyncTime() async {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let lastSyncURL = cacheURL.appendingPathComponent("last_sync_time.json")

        guard FileManager.default.fileExists(atPath: lastSyncURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: lastSyncURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            lastSyncTime = try decoder.decode(Date.self, from: data)
        } catch {
            print("最後の同期時間の読み込みに失敗しました: \(error)")
        }
    }

    // MARK: - Background Sync

    /// バックグラウンド同期
    func syncInBackground() async {
        guard !isSyncing else {
            return
        }

        do {
            _ = try await syncAllData()
            print("バックグラウンド同期が完了しました")
        } catch {
            print("バックグラウンド同期に失敗しました: \(error)")
        }
    }

    // MARK: - Manual Sync Trigger

    /// 手動同期トリガー（ユーザー操作による同期）
    func syncManually() async throws -> SyncResult {
        return try await syncAllData()
    }
}

// MARK: - Supporting Types

protocol Syncable {
    var updatedAt: Date { get }
}

extension LearningLog: Syncable {}

struct SyncResult {
    var syncedLogs: Int
    var failedLogs: Int
    var syncDuration: TimeInterval
    var syncedAt: Date
    var error: Error?

    var totalSynced: Int {
        syncedLogs
    }

    var totalFailed: Int {
        failedLogs
    }

    var successRate: Double {
        let total = totalSynced + totalFailed
        return total > 0 ? Double(totalSynced) / Double(total) : 0
    }
}

struct SyncItemResult {
    var synced: Int
    var failed: Int
}

enum SyncError: LocalizedError {
    case syncInProgress
    case networkUnavailable
    case authenticationRequired
    case conflictDetected
    case unknown

    var errorDescription: String? {
        switch self {
        case .syncInProgress:
            return "同期が進行中です"
        case .networkUnavailable:
            return "ネットワーク接続が利用できません"
        case .authenticationRequired:
            return "認証が必要です"
        case .conflictDetected:
            return "同期コンフリクトが検出されました"
        case .unknown:
            return "不明なエラー"
        }
    }
}
