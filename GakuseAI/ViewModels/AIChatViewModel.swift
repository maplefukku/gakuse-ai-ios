import Foundation
import SwiftUI

@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessageData] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let persistenceService = PersistenceService.shared
    private let apiService = APIService.shared
    
    init() {
        Task {
            await loadHistory()
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
}
