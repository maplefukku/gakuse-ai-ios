import Foundation
import Supabase

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
    
    // MARK: - AI Chat
    
    func sendChatMessage(_ text: String, history: [ChatMessageData]) async throws -> ChatMessageData {
        // TODO: 実際のAI APIと連携
        // 現在はモックレスポンスを返す
        // 将来的にはOpenAI APIや自社APIを使用
        
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒待機
        
        // 文脈を考慮したモックレスポンス
        let responses = generateMockResponse(for: text, history: history)
        return ChatMessageData(content: responses, isUser: false)
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
