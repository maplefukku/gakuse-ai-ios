import Foundation
import Supabase
import Network

// MARK: - API Error

enum APIError: LocalizedError {
    case unauthenticated
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case unknown
    case offline
    case timeout

    var errorDescription: String? {
        switch self {
        case .unauthenticated:
            return "認証が必要です"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .httpError(let statusCode):
            return "HTTPエラー: \(statusCode)"
        case .decodingError(let error):
            return "デコードエラー: \(error.localizedDescription)"
        case .encodingError(let error):
            return "エンコードエラー: \(error.localizedDescription)"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        case .offline:
            return "オフラインです"
        case .timeout:
            return "タイムアウトしました"
        case .unknown:
            return "不明なエラー"
        }
    }
}

actor APIService {
    static let shared = APIService()

    private let baseURL: URL
    private let supabase = SupabaseManager.shared
    private let session: URLSession
    private let cache = CacheService.shared
    private let networkMonitor = NWPathMonitor()
    private nonisolated(unsafe) var isOnline = true

    init() {
        // Info.plistからAPI Base URLを取得
        guard let apiBaseURLString = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
              let apiBaseURL = URL(string: apiBaseURLString),
              !apiBaseURLString.isEmpty else {
            fatalError("API Base URL must be set in Info.plist")
        }

        self.baseURL = apiBaseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        
        // ネットワーク監視を初期化
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isOnline = path.status == .satisfied
        }
        networkMonitor.start(queue: queue)
    }
    
    // MARK: - Network Monitoring

    nonisolated var isConnected: Bool {
        isOnline
    }
    
    // MARK: - Helper
    
    private func getAuthToken() async throws -> String? {
        let session = try await supabase.currentSession
        return session?.accessToken
    }

    // MARK: - Retry Logic

    private func performWithRetry<T>(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        operation: () async throws -> T
    ) async throws -> T {
        var lastError: Error?

        for attempt in 0..<maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error

                // リトライすべきエラーか判断
                guard shouldRetry(error: error) else {
                    throw error
                }

                // 最後の試行であれば待機しない
                guard attempt < maxRetries - 1 else {
                    break
                }

                // 指数バックオフで待機
                let delay = baseDelay * pow(2.0, Double(attempt))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        throw lastError ?? APIError.unknown
    }

    private func shouldRetry(error: Error) -> Bool {
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError, .timeout:
                return true
            case .httpError(let statusCode):
                // 5xxエラーの場合はリトライ
                return statusCode >= 500
            default:
                return false
            }
        }

        // URLErrorの場合
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .notConnectedToInternet, .networkConnectionLost, .dnsLookupFailed:
                return true
            default:
                return false
            }
        }

        return false
    }
    
    // MARK: - Learning Logs

    func fetchLearningLogs() async throws -> [LearningLog] {
        // オフラインチェック
        if !isConnected {
            // キャッシュされたデータを返す
            if let cachedLogs = try await cache.getCachedLearningLogs() {
                return cachedLogs
            }
            throw APIError.offline
        }

        // リトライロジックを適用して学習ログを取得
        let logs: [LearningLog] = try await performWithRetry {
            guard let token = try await self.getAuthToken() else {
                throw APIError.unauthenticated
            }

            var request = URLRequest(url: URL(string: "\(self.baseURL)/learning-logs")!)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await self.session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let decodedLogs = try decoder.decode([LearningLog].self, from: data)

            // キャッシュに保存
            try? await self.cache.cacheLearningLogs(decodedLogs)

            return decodedLogs
        }

        return logs
    }

    func createLearningLog(_ log: LearningLog) async throws -> LearningLog {
        // リトライロジックを適用して学習ログを作成
        return try await performWithRetry {
            guard let token = try await self.getAuthToken() else {
                throw APIError.unauthenticated
            }

            var request = URLRequest(url: URL(string: "\(self.baseURL)/learning-logs")!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(log)

            let (data, response) = try await self.session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard httpResponse.statusCode == 201 else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let createdLog = try decoder.decode(LearningLog.self, from: data)
            return createdLog
        }
    }

    func updateLearningLog(_ log: LearningLog) async throws -> LearningLog {
        // リトライロジックを適用して学習ログを更新
        return try await performWithRetry {
            guard let token = try await self.getAuthToken() else {
                throw APIError.unauthenticated
            }

            var request = URLRequest(url: URL(string: "\(self.baseURL)/learning-logs/\(log.id.uuidString)")!)
            request.httpMethod = "PUT"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(log)

            let (data, response) = try await self.session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let updatedLog = try decoder.decode(LearningLog.self, from: data)
            return updatedLog
        }
    }

    func deleteLearningLog(id: UUID) async throws {
        // リトライロジックを適用して学習ログを削除
        try await performWithRetry {
            guard let token = try await self.getAuthToken() else {
                throw APIError.unauthenticated
            }

            var request = URLRequest(url: URL(string: "\(self.baseURL)/learning-logs/\(id.uuidString)")!)
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (_, response) = try await self.session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard httpResponse.statusCode == 204 else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
        }
    }
    
    // MARK: - AI Chat

    func sendChatMessage(_ text: String, history: [ChatMessageData]) async throws -> ChatMessageData {
        // AI APIエンドポイントが設定されている場合は実際のAPIを呼び出し、
        // 設定されていない場合はモックレスポンスを返す
        guard let aiAPIEndpoint = Bundle.main.object(forInfoDictionaryKey: "AIAPIEndpoint") as? String,
              !aiAPIEndpoint.isEmpty,
              let endpointURL = URL(string: aiAPIEndpoint) else {
            // AI APIエンドポイントが設定されていない場合はモックを使用
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒待機

            // 文脈を考慮したモックレスポンス
            let responses = generateMockResponse(for: text, history: history)
            return ChatMessageData(
                id: UUID(),
                content: responses,
                isUser: false,
                timestamp: Date()
            )
        }

        // オフラインチェック
        if !isConnected {
            // オフラインの場合はモックレスポンスを返す
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒待機
            let responses = generateMockResponse(for: text, history: history)
            return ChatMessageData(
                id: UUID(),
                content: responses,
                isUser: false,
                timestamp: Date()
            )
        }

        // リトライロジックを適用してAI APIを呼び出す
        let aiResponse: ChatMessageData = try await performWithRetry {
            guard let token = try await self.getAuthToken() else {
                throw APIError.unauthenticated
            }

            var request = URLRequest(url: endpointURL)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let requestBody: [String: Any] = [
                "message": text,
                "history": history.map { ["id": $0.id.uuidString, "content": $0.content, "isUser": $0.isUser] }
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            let (data, urlResponse) = try await self.session.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let response = try decoder.decode(ChatMessageData.self, from: data)

            // キャッシュに保存
            try? await self.cache.cacheChatHistory(history + [response])

            return response
        }

        return aiResponse
    }
    
    private func generateMockResponse(for text: String, history: [ChatMessageData]) -> String {
        // SOUL.mdのビジョンに沿った壁打ちスタイルのレスポンス
        let lowercased = text.lowercased()
        
        // 会話履歴を分析して文脈を取得
        let context = analyzeConversationContext(history)
        
        // ユーザーの入力に基づいて適切なレスポンスを選択
        if lowercased.contains("目標") || lowercased.contains("ゴール") {
            return generateGoalResponse(text, context: context)
        }
        
        if lowercased.contains("プロジェクト") || lowercased.contains("取り組んで") {
            return generateProjectResponse(text, context: context)
        }
        
        if lowercased.contains("キャリア") || lowercased.contains("将来") || lowercased.contains("仕事") {
            return generateCareerResponse(text, context: context)
        }
        
        if lowercased.contains("学習") || lowercased.contains("勉強") || lowercased.contains("計画") {
            return generateLearningResponse(text, context: context)
        }
        
        if lowercased.contains("アイデア") || lowercased.contains("考え") {
            return generateIdeaResponse(text, context: context)
        }
        
        // デフォルトレスポンス
        return generateDefaultResponse(text, context: context)
    }
    
    // MARK: - Context Analysis
    
    private struct ConversationContext {
        var mentionedTopics: Set<String>
        var userInterests: Set<String>
        var recentThemes: [String]
        var conversationDepth: Int
        
        init() {
            mentionedTopics = []
            userInterests = []
            recentThemes = []
            conversationDepth = 0
        }
    }
    
    private func analyzeConversationContext(_ history: [ChatMessageData]) -> ConversationContext {
        var context = ConversationContext()
        
        // 直近のユーザーメッセージを分析（最大5件）
        let recentMessages = history.filter { $0.isUser }.suffix(5)
        
        for message in recentMessages {
            let text = message.content.lowercased()
            context.conversationDepth += 1
            
            // トピック抽出
            let topics = extractTopics(from: text)
            context.mentionedTopics.formUnion(topics)
            
            // ユーザーの興味推定
            let interests = extractInterests(from: text)
            context.userInterests.formUnion(interests)
            
            // テーマ抽出
            if let theme = extractTheme(from: text) {
                context.recentThemes.append(theme)
            }
        }
        
        return context
    }
    
    private func extractTopics(from text: String) -> Set<String> {
        var topics: Set<String> = []
        
        let topicKeywords = [
            ("プログラミング", ["swift", "ios", "コード", "アプリ"]),
            ("デザイン", ["ui", "ux", "デザイン", "レイアウト"]),
            ("ビジネス", ["起業", "ビジネス", "マーケティング"]),
            ("語学", ["英語", "語学", "翻訳"]),
            ("キャリア", ["仕事", "キャリア", "転職"])
        ]
        
        for (topic, keywords) in topicKeywords {
            if keywords.contains(where: { text.contains($0) }) {
                topics.insert(topic)
            }
        }
        
        return topics
    }
    
    private func extractInterests(from text: String) -> Set<String> {
        var interests: Set<String> = []
        
        let interestKeywords = [
            ("クリエイティブ", ["クリエイティブ", "創造", "表現"]),
            ("学習", ["学び", "勉強", "成長"]),
            ("技術", ["技術", "開発", "プログラム"]),
            ("人間関係", ["人間関係", "コミュニケーション", "チーム"])
        ]
        
        for (interest, keywords) in interestKeywords {
            if keywords.contains(where: { text.contains($0) }) {
                interests.insert(interest)
            }
        }
        
        return interests
    }
    
    private func extractTheme(from text: String) -> String? {
        if text.contains("目標") || text.contains("ゴール") {
            return "目標設定"
        } else if text.contains("プロジェクト") {
            return "プロジェクト開発"
        } else if text.contains("キャリア") {
            return "キャリア"
        } else if text.contains("学習") {
            return "学習"
        } else if text.contains("アイデア") {
            return "アイデア出し"
        }
        return nil
    }
    
    // MARK: - Response Generators
    
    private func generateGoalResponse(_ text: String, context: ConversationContext) -> String {
        var response = """
        その目標、とても面白いですね！
        """
        
        if context.conversationDepth > 1 {
            response += """
            
            前回の会話から、\(context.mentionedTopics.joined(separator: "・"))に関心があることが分かりましたね。
            """
        }
        
        response += """
        
        もう少し深掘りさせてください：
        
        1. **なぜ**その目標を選んだのですか？
        2. それを達成したら、**どう変わっていたい**ですか？
        3. 今、そのための**最初の一歩**は何ですか？
        """
        
        if context.userInterests.contains("クリエイティブ") {
            response += """
            
            ちなみに、あなたのクリエイティブな視点は、この目標の達成に役立ちそうですね！
            """
        }
        
        response += """
        
        小さく始めて、素早く学ぶ。それが大切です。
        """
        
        return response
    }
    
    private func generateProjectResponse(_ text: String, context: ConversationContext) -> String {
        var response = """
        素晴らしいプロジェクトですね！壁打ちとして質問させてもらいます：
        """
        
        if !context.mentionedTopics.isEmpty {
            response += """
            
            \(context.mentionedTopics.joined(separator: "・"))の領域で、
            """
        }
        
        response += """
        
        - このプロジェクトで**一番学びたいこと**は何ですか？
        - **誰のために**作っていますか？
        - **2週間で**どこまで進められそうですか？
        
        完璧を目指すより、まずは動くものを。 🙂
        """
        
        if context.conversationDepth > 2 {
            response += """
            
            これまでの会話から、あなたのスタイルが見えてきましたね。
            焦らず、一つずつ進めましょう！
            """
        }
        
        return response
    }
    
    private func generateCareerResponse(_ text: String, context: ConversationContext) -> String {
        var response = """
        キャリアの方向性、大事なテーマですね。
        
        あなたが**ワクワクすること**は何ですか？
        
        逆に、**絶対にやりたくないこと**は？
        """
        
        if context.userInterests.contains("技術") && context.userInterests.contains("人間関係") {
            response += """
            
            技術と人間関係の両方に興味があるんですね。
            これは大きな強みです！
            """
        }
        
        response += """
        
        その間に、あなたが得意で、世の中が必要としている何かがあるはずです。
        """
        
        if !context.recentThemes.isEmpty {
            response += """
            
            \(context.recentThemes.joined(separator: "、"))を通して、
            もっと自分自身のことが分かってきたのではないでしょうか？
            """
        }
        
        return response
    }
    
    private func generateLearningResponse(_ text: String, context: ConversationContext) -> String {
        var response = """
        学習計画ですね！いくつかアドバイスさせてください：
        
        📚 **パレートの法則**：成果の80%は行動の20%から生まれます
        🔄 **PDCA**：計画→実行→評価→改善のサイクルを回す
        🎯 **1日1つの小さな成果**：毎日何かをアウトプットする
        """
        
        if context.conversationDepth > 1 {
            let learningCount = context.mentionedTopics.filter { ["学習", "勉強", "成長"].contains($0) }.count
            if learningCount > 1 {
                response += """
                
                継続的に学習に取り組まれているんですね！
                その姿勢こそが、最大の資産です。
                """
            }
        }
        
        response += """
        
        今週、何をアウトプットしますか？
        """
        
        if context.userInterests.contains("学習") {
            response += """
            
            学びへの情熱を感じますね！
            無理せず、楽しんで続けましょう。
            """
        }
        
        return response
    }
    
    private func generateIdeaResponse(_ text: String, context: ConversationContext) -> String {
        var response = """
        そのアイデア、面白いですね！
        
        少し視点を変えてみましょう：
        
        - **逆**にしたらどうなりますか？
        - **10倍スケール**したら？
        - **誰かが既にやってたら**、どう差別化しますか？
        """
        
        if context.conversationDepth > 1 && context.userInterests.contains("クリエイティブ") {
            response += """
            
            あなたのクリエイティブな思考力が活きそうですね！
            既にいくつかのアイデアを出されているので、
            今回はそれらを組み合わせてみてはいかがでしょうか？
            """
        }
        
        response += """
        
        アイデアは出すだけじゃなく、検証してなんぼです 💡
        """
        
        if context.recentThemes.contains("プロジェクト開発") {
            response += """
            
            プロジェクトの文脈から考えると、
            最小限のプロトタイプを作って、
            早速フィードバックをもらうのが良いかもしれません。
            """
        }
        
        return response
    }
    
    private func generateDefaultResponse(_ text: String, context: ConversationContext) -> String {
        var response = """
        そうですね、もう少し教えていただけますか？
        
        - 何を**きっかけ**でその考えに至りましたか？
        - **一番の課題**は何ですか？
        - **今日できること**はありますか？
        """
        
        if context.conversationDepth > 1 {
            response += """
            
            これまでの会話から、\(context.mentionedTopics.prefix(3).joined(separator: "・"))について
            考えてこられたんですね。
            """
        }
        
        if !context.userInterests.isEmpty {
            response += """
            
            \(context.userInterests.prefix(2).joined(separator: "・"))に関心があるんですね。
            その視点を大切にしていきましょう。
            """
        }
        
        response += """
        
        小さな一歩が、大きな変化を生みます。
        """
        
        return response
    }
}
