import Foundation
import SwiftUI

@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessageData] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedMessage: ChatMessageData? = nil
    @Published var showingDeleteConfirmation = false
    @Published var showingShareSheet = false
    @Published var messageToShare: String? = nil
    @Published var showingExportSheet = false
    @Published var exportURL: URL? = nil
    @Published var isExporting = false
    @Published var suggestedPrompts: [String] = []
    
    private let persistenceService = PersistenceService.shared
    private let apiService = APIService.shared
    
    init() {
        Task {
            await loadHistory()
            await generatePrompts()
        }
    }
    
    func loadHistory() async {
        do {
            messages = try await persistenceService.loadChatHistory()
        } catch {
            // 初回は空配列でOK
            messages = []
        }
    }
    
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // ユーザーメッセージを追加
        let userMessage = ChatMessageData(content: text, isUser: true)
        messages.append(userMessage)
        inputText = ""
        
        // 保存
        do {
            try await persistenceService.appendChatMessage(userMessage)
        } catch {
            print("保存エラー: \(error)")
        }
        
        // AI応答を取得
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await apiService.sendChatMessage(text, history: messages)
            messages.append(response)
            try await persistenceService.appendChatMessage(response)
        } catch {
            errorMessage = "AI応答エラー: \(error.localizedDescription)"
            // エラー時もダミー応答で継続性を保つ
            let fallbackResponse = ChatMessageData(
                content: "申し訳ありません。一時的に応答できません。しばらく待ってから再度お試しください。",
                isUser: false
            )
            messages.append(fallbackResponse)
        }
    }
    
    func clearHistory() async {
        do {
            try await persistenceService.clearChatHistory()
            messages = []
        } catch {
            errorMessage = "履歴削除エラー: \(error.localizedDescription)"
        }
    }
    
    func useSuggestedPrompt(_ prompt: String) {
        inputText = prompt
    }
    
    /// 学習ログからプロンプトを生成
    func generatePrompts() async {
        let defaultPrompts = [
            "今取り組んでいるプロジェクトについて話したい",
            "キャリアの方向性について相談したい",
            "学習計画のフィードバックが欲しい",
            "アイデアをブラッシュアップしたい"
        ]
        
        do {
            let logs = try await persistenceService.loadLearningLogs()
            
            // 学習ログからキーワードを抽出してプロンプトを生成
            let categoryBasedPrompts = logs.prefix(3).compactMap { log in
                switch log.category {
                case .programming:
                    return "プログラミング学習：\(log.title)について深く議論したい"
                case .design:
                    return "デザイン学習：\(log.title)についてアドバイスが欲しい"
                case .business:
                    return "ビジネス学習：\(log.title)の実践方法を教えて"
                case .language:
                    return "語学学習：\(log.title)の効果的な勉強法を知りたい"
                case .creative:
                    return "クリエイティブ学習：\(log.title)についてアイデアを出してほしい"
                case .other:
                    return "学習：\(log.title)についてアドバイスが欲しい"
                }
            }
            
            // スキルに基づくプロンプト
            let skillBasedPrompts = Set(logs.flatMap { $0.skills.map { $0.name } })
                .prefix(5)
                .map { skill in
                    "\(skill)スキルの上達方法を教えて"
                }
            
            // デフォルトプロンプトと生成プロンプトをマージ
            suggestedPrompts = Array(Set(categoryBasedPrompts + skillBasedPrompts + defaultPrompts))
                .shuffled()
                .prefix(8)
                .map { $0 }
        } catch {
            // エラー時はデフォルトプロンプトを使用
            suggestedPrompts = defaultPrompts
        }
    }
    
    /// リフレッシュボタンでプロンプトを再生成
    func refreshPrompts() async {
        await generatePrompts()
    }
    
    // MARK: - Message Actions
    
    func copyMessage(_ message: ChatMessageData) {
        #if os(iOS)
        UIPasteboard.general.string = message.content
        #elseif os(macOS)
        NSPasteboard.general.setString(message.content, forType: .string)
        #endif
    }
    
    func prepareDeleteMessage(_ message: ChatMessageData) {
        selectedMessage = message
        showingDeleteConfirmation = true
    }
    
    func deleteMessage() async {
        guard let message = selectedMessage else { return }
        
        // ローカル配列から削除
        messages.removeAll { $0.id == message.id }
        
        // 永続化（履歴を上書き）
        do {
            try await persistenceService.saveChatHistory(messages)
        } catch {
            errorMessage = "削除エラー: \(error.localizedDescription)"
        }
        
        selectedMessage = nil
        showingDeleteConfirmation = false
    }
    
    func shareMessage(_ message: ChatMessageData) {
        messageToShare = message.content
        showingShareSheet = true
    }
    
    func exportChatHistory() async {
        isExporting = true
        defer { isExporting = false }
        
        do {
            let url = try await persistenceService.exportAllData()
            exportURL = url
            showingExportSheet = true
        } catch {
            errorMessage = "エクスポートエラー: \(error.localizedDescription)"
        }
    }
}
