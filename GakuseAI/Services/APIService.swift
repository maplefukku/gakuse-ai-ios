import Foundation
import Supabase

// MARK: - API Error

enum APIError: LocalizedError {
    case unauthenticated
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case unknown

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
        case .unknown:
            return "不明なエラー"
        }
    }
}

actor APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api.gakuse.ai" // TODO: Configure actual API URL
    private let supabase = SupabaseManager.shared
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Helper
    
    private func getAuthToken() async throws -> String? {
        let session = try await supabase.currentSession
        return session?.accessToken
    }
    
    // MARK: - Learning Logs

    func fetchLearningLogs() async throws -> [LearningLog] {
        // Supabase REST APIを使用して学習ログを取得
        guard let token = try await getAuthToken() else {
            throw APIError.unauthenticated
        }

        var request = URLRequest(url: URL(string: "\(baseURL)/learning-logs")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let logs = try decoder.decode([LearningLog].self, from: data)
        return logs
    }

    func createLearningLog(_ log: LearningLog) async throws -> LearningLog {
        // Supabase REST APIを使用して学習ログを作成
        guard let token = try await getAuthToken() else {
            throw APIError.unauthenticated
        }

        var request = URLRequest(url: URL(string: "\(baseURL)/learning-logs")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(log)

        let (data, response) = try await session.data(for: request)

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

    func updateLearningLog(_ log: LearningLog) async throws -> LearningLog {
        guard let token = try await getAuthToken() else {
            throw APIError.unauthenticated
        }

        var request = URLRequest(url: URL(string: "\(baseURL)/learning-logs/\(log.id.uuidString)")!)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(log)

        let (data, response) = try await session.data(for: request)

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

    func deleteLearningLog(id: UUID) async throws {
        guard let token = try await getAuthToken() else {
            throw APIError.unauthenticated
        }

        var request = URLRequest(url: URL(string: "\(baseURL)/learning-logs/\(id.uuidString)")!)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 204 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
    
    // MARK: - AI Chat

    func sendChatMessage(_ text: String, history: [ChatMessageData]) async throws -> ChatMessageData {
        // 実際のAI APIと連携（TODO: OpenAI APIや自社APIを使用）
        // 現在はモックレスポンスを返す

        // TODO: 将来的には以下のようなAPI呼び出しを実装
        // guard let token = try await getAuthToken() else {
        //     throw APIError.unauthenticated
        // }
        //
        // var request = URLRequest(url: URL(string: "\(baseURL)/ai/chat")!)
        // request.httpMethod = "POST"
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //
        // let requestBody = ["message": text, "history": history.map { $0.toDictionary() }]
        // request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        //
        // let (data, response) = try await session.data(for: request)
        // ...

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
    
    private func generateMockResponse(for text: String, history: [ChatMessageData]) -> String {
        // SOUL.mdのビジョンに沿った壁打ちスタイルのレスポンス
        let lowercased = text.lowercased()
        
        if lowercased.contains("目標") || lowercased.contains("ゴール") {
            return """
            その目標、とても面白いですね！もう少し深掘りさせてください：
            
            1. **なぜ**その目標を選んだのですか？
            2. それを達成したら、**どう変わっていたい**ですか？
            3. 今、そのための**最初の一歩**は何ですか？
            
            小さく始めて、素早く学ぶ。それが大切です。
            """
        }
        
        if lowercased.contains("プロジェクト") || lowercased.contains("取り組んで") {
            return """
            素晴らしいプロジェクトですね！壁打ちとして質問させてもらいます：
            
            - このプロジェクトで**一番学びたいこと**は何ですか？
            - **誰のために**作っていますか？
            - **2週間で**どこまで進められそうですか？
            
            完璧を目指すより、まずは動くものを。 🙂
            """
        }
        
        if lowercased.contains("キャリア") || lowercased.contains("将来") || lowercased.contains("仕事") {
            return """
            キャリアの方向性、大事なテーマですね。
            
            あなたが**ワクワクすること**は何ですか？
            
            逆に、**絶対にやりたくないこと**は？
            
            その間に、あなたが得意で、世の中が必要としている何かがあるはずです。
            """
        }
        
        if lowercased.contains("学習") || lowercased.contains("勉強") || lowercased.contains("計画") {
            return """
            学習計画ですね！いくつかアドバイスさせてください：
            
            📚 **パレートの法則**：成果の80%は行動の20%から生まれます
            🔄 **PDCA**：計画→実行→評価→改善のサイクルを回す
            🎯 **1日1つの小さな成果**：毎日何かをアウトプットする
            
            今週、何をアウトプットしますか？
            """
        }
        
        if lowercased.contains("アイデア") || lowercased.contains("考え") {
            return """
            そのアイデア、面白いですね！
            
            少し視点を変えてみましょう：
            
            - **逆**にしたらどうなりますか？
            - **10倍スケール**したら？
            - **誰かが既にやってたら**、どう差別化しますか？
            
            アイデアは出すだけじゃなく、検証してなんぼです 💡
            """
        }
        
        // デフォルトレスポンス
        return """
        そうですね、もう少し教えていただけますか？
        
        - 何を**きっかけ**でその考えに至りましたか？
        - **一番の課題**は何ですか？
        - **今日できること**はありますか？
        
        小さな一歩が、大きな変化を生みます。
        """
    }
}
