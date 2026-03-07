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
    @Published var suggestedPrompts: [SuggestedPrompt] = []
    @Published var messageSearchText = ""
    @Published var selectedPromptCategory: PromptCategory? = nil
    
    private let persistenceService = PersistenceService.shared
    private let apiService = APIService.shared
    
    init() {
        Task {
            await loadHistory()
            await generatePrompts()
        }
    }
    
    // MARK: - Messages
    
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
        let userMessage = ChatMessageData(
            id: UUID(),
            content: text,
            isUser: true,
            timestamp: Date()
        )
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
                id: UUID(),
                content: "申し訳ありません。一時的に応答できません。しばらく待ってから再度お試しください。",
                isUser: false,
                timestamp: Date()
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
    
    // MARK: - Search
    
    /// 検索フィルター適用後のメッセージ
    var filteredMessages: [ChatMessageData] {
        if messageSearchText.isEmpty {
            return messages
        }
        return messages.filter { message in
            message.content.localizedCaseInsensitiveContains(messageSearchText)
        }
    }
    
    /// 日付でグループ化したメッセージ
    var groupedMessages: [GroupedMessage] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredMessages) { message in
            calendar.startOfDay(for: message.timestamp)
        }
        
        return grouped
            .map { (date: $0.key, messages: $0.value) }
            .sorted { $0.date > $1.date }
            .map { item in
                GroupedMessage(id: item.date.timeIntervalSince1970, date: item.date, messages: item.messages)
            }
    }
    
    // MARK: - Prompts
    
    func useSuggestedPrompt(_ prompt: String) {
        inputText = prompt
    }
    
    func useSuggestedPromptItem(_ item: SuggestedPrompt) {
        inputText = item.text
    }
    
    /// 学習ログからプロンプトを生成
    func generatePrompts() async {
        let defaultPrompts: [SuggestedPrompt] = [
            SuggestedPrompt(text: "今取り組んでいるプロジェクトについて話したい", category: .general, icon: "briefcase.fill"),
            SuggestedPrompt(text: "キャリアの方向性について相談したい", category: .general, icon: "arrow.up.forward"),
            SuggestedPrompt(text: "学習計画のフィードバックが欲しい", category: .learning, icon: "book.fill"),
            SuggestedPrompt(text: "アイデアをブラッシュアップしたい", category: .creative, icon: "lightbulb.fill")
        ]
        
        do {
            let logs = try await persistenceService.loadLearningLogs()
            
            // 学習ログからキーワードを抽出してプロンプトを生成
            var categoryBasedPrompts: [SuggestedPrompt] = []
            
            for log in logs.prefix(3) {
                let promptText: String
                let category: PromptCategory
                let icon: String
                
                switch log.category {
                case .programming:
                    promptText = "プログラミング学習：\(log.title)について深く議論したい"
                    category = .programming
                    icon = "chevron.left.forwardslash.chevron.right"
                case .design:
                    promptText = "デザイン学習：\(log.title)についてアドバイスが欲しい"
                    category = .design
                    icon = "paintbrush.fill"
                case .business:
                    promptText = "ビジネス学習：\(log.title)の実践方法を教えて"
                    category = .business
                    icon = "briefcase.fill"
                case .language:
                    promptText = "語学学習：\(log.title)の効果的な勉強法を知りたい"
                    category = .language
                    icon = "globe"
                case .creative:
                    promptText = "クリエイティブ学習：\(log.title)についてアイデアを出してほしい"
                    category = .creative
                    icon = "sparkles"
                case .other:
                    promptText = "学習：\(log.title)についてアドバイスが欲しい"
                    category = .other
                    icon = "star.fill"
                }
                
                categoryBasedPrompts.append(SuggestedPrompt(text: promptText, category: category, icon: icon))
            }
            
            // スキルに基づくプロンプト
            let skillBasedPrompts = Set(logs.flatMap { $0.skills.map { $0.name } })
                .prefix(5)
                .map { skill in
                    SuggestedPrompt(
                        text: "\(skill)スキルの上達方法を教えて",
                        category: .skills,
                        icon: "star.fill"
                    )
                }
            
            // 日付に基づくプロンプト
            let calendar = Calendar.current
            let today = Date()
            
            var dateBasedPrompts: [SuggestedPrompt] = []
            
            // 今日の学習
            let todayLogs = logs.filter { calendar.isDateInToday($0.createdAt) }
            if !todayLogs.isEmpty {
                dateBasedPrompts.append(SuggestedPrompt(
                    text: "今日の学習を振り返ってほしい",
                    category: .daily,
                    icon: "calendar.badge.clock"
                ))
            }
            
            // 今週の学習
            let weekLogs = logs.filter { calendar.isDate($0.createdAt, inSameDayAs: calendar.date(byAdding: .day, value: -7, to: today)!) }
            if !weekLogs.isEmpty {
                dateBasedPrompts.append(SuggestedPrompt(
                    text: "今週の学習を総括してほしい",
                    category: .weekly,
                    icon: "calendar.badge.weekday"
                ))
            }
            
            // デフォルトプロンプトと生成プロンプトをマージ
            let allPrompts = defaultPrompts + categoryBasedPrompts + skillBasedPrompts + dateBasedPrompts
            suggestedPrompts = Array(Set(allPrompts))
                .shuffled()
                .prefix(10)
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
    
    /// カテゴリでフィルターされたプロンプト
    var filteredPrompts: [SuggestedPrompt] {
        if let category = selectedPromptCategory {
            return suggestedPrompts.filter { $0.category == category }
        }
        return suggestedPrompts
    }
    
    // MARK: - Message Actions
    
    func copyMessage(_ message: ChatMessageData) {
        UIPasteboard.general.string = message.content
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
    
    func regenerateResponse(for message: ChatMessageData) async {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        
        // このメッセージ以降のメッセージを削除
        messages = Array(messages.prefix(index + 1))
        
        // ユーザーメッセージを再送
        if let lastMessage = messages.last, lastMessage.isUser {
            // 直前のメッセージがユーザーメッセージの場合、そのテキストを再送
            let text = lastMessage.content
            inputText = text
            await sendMessage()
        }
    }
    
    // MARK: - Export
    
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
    
    /// Markdown形式でチャット履歴をエクスポート
    func exportChatHistoryToMarkdown() async -> URL? {
        let fileName = "chat_history_\(Date().timeIntervalSince1970).md"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        var markdownContent = "# AI壁打ち履歴\n\n"
        markdownContent += "エクスポート日時: \(Date())\n\n"
        
        for (index, message) in messages.enumerated() {
            let role = message.isUser ? "ユーザー" : "AI"
            markdownContent += "## \(index + 1). \(role)\n\n"
            markdownContent += "\(message.content)\n\n"
            markdownContent += "---\n\n"
        }
        
        do {
            try markdownContent.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            errorMessage = "エクスポートエラー: \(error.localizedDescription)"
            return nil
        }
    }
}

// MARK: - Grouped Message Model

struct GroupedMessage: Identifiable {
    let id: TimeInterval
    let date: Date
    let messages: [ChatMessageData]
}

// MARK: - Suggested Prompt Model

struct SuggestedPrompt: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let category: PromptCategory
    let icon: String
}

enum PromptCategory: String, CaseIterable {
    case general = "一般"
    case learning = "学習"
    case programming = "プログラミング"
    case design = "デザイン"
    case business = "ビジネス"
    case language = "語学"
    case creative = "クリエイティブ"
    case skills = "スキル"
    case daily = "今日"
    case weekly = "今週"
    case other = "その他"
    
    var icon: String {
        switch self {
        case .general: return "ellipsis.circle"
        case .learning: return "book.fill"
        case .programming: return "chevron.left.forwardslash.chevron.right"
        case .design: return "paintbrush.fill"
        case .business: return "briefcase.fill"
        case .language: return "globe"
        case .creative: return "sparkles"
        case .skills: return "star.fill"
        case .daily: return "calendar.badge.clock"
        case .weekly: return "calendar.badge.weekday"
        case .other: return "star.fill"
        }
    }
}
