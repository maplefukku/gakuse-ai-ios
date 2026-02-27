import SwiftUI

struct AIChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if messages.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.pink.opacity(0.6))
                        
                        Text("AI壁打ち")
                            .font(.title.bold())
                        
                        Text("目標やアイデアを壁打ちして、\nより深い理解を得ましょう")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 12) {
                            SuggestedPrompt(text: "今取り組んでいるプロジェクトについて話したい")
                            SuggestedPrompt(text: "キャリアの方向性について相談したい")
                            SuggestedPrompt(text: "学習計画のフィードバックが欲しい")
                        }
                        .padding()
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { message in
                                    MessageBubble(message: message)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) {
                            if let lastMessage = messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Input Bar
                HStack(spacing: 12) {
                    TextField("メッセージを入力...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                    
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.pink)
                            .cornerRadius(8)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("AI壁打ち")
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messages.append(ChatMessage(content: text, isUser: true))
        inputText = ""
        
        // TODO: Implement actual AI response
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                messages.append(ChatMessage(
                    content: "そうですね、その点についてもう少し教えていただけますか？",
                    isUser: false
                ))
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isUser ? Color.pink : Color(.systemGray5))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
            
            if !message.isUser { Spacer() }
        }
    }
}

struct SuggestedPrompt: View {
    let text: String
    
    var body: some View {
        Button {
            // TODO: Implement
        } label: {
            Text(text)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    AIChatView()
}
