import SwiftUI

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.messages.isEmpty {
                    emptyStateView
                } else {
                    chatListView
                }

                inputBar
            }
            .navigationTitle("AI壁打ち")
            .searchable(text: $viewModel.messageSearchText, prompt: "メッセージを検索...")
            .accessibilityElement(children: .contain)
            .accessibilityLabel("AI壁打ちチャット")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            Task {
                                await viewModel.clearHistory()
                            }
                        } label: {
                            Label("履歴をクリア", systemImage: "trash")
                        }

                        Menu {
                            Button {
                                Task {
                                    await viewModel.exportChatHistory()
                                }
                            } label: {
                                Label("JSON形式", systemImage: "doc.text")
                            }

                            Button {
                                Task {
                                    if let url = await viewModel.exportChatHistoryToMarkdown() {
                                        viewModel.exportURL = url
                                        viewModel.showingExportSheet = true
                                    }
                                }
                            } label: {
                                Label("Markdown形式", systemImage: "doc.text")
                            }
                        } label: {
                            Label("履歴をエクスポート", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("メニューボタン")
                    .accessibilityHint("履歴のクリアやエクスポートができます")
                }
            }
            .alert("エラー", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .confirmationDialog("メッセージを削除", isPresented: $viewModel.showingDeleteConfirmation) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    Task {
                        await viewModel.deleteMessage()
                    }
                }
            } message: {
                Text("このメッセージを削除しますか？")
            }
            .sheet(isPresented: $viewModel.showingShareSheet) {
                if let text = viewModel.messageToShare {
                    ShareSheet(items: [text] as [Any])
                }
            }
            .sheet(isPresented: $viewModel.showingExportSheet) {
                if let url = viewModel.exportURL {
                    ShareSheet(items: [url] as [Any])
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("AI壁打ち")
                    .font(.title.bold())
                
                Text("目標やアイデアを壁打ちして、\nより深い理解を得ましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("おすすめのトピック")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button {
                        Task {
                            await viewModel.refreshPrompts()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
                
                // カテゴリフィルター
                if !viewModel.filteredPrompts.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            AllPromptsButton(viewModel: viewModel)
                            ForEach(PromptCategory.allCases, id: \.self) { category in
                                CategoryFilterButton(category: category, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // プロンプト一覧
                ForEach(viewModel.filteredPrompts) { prompt in
                    SuggestedPromptButton(prompt: prompt) {
                        viewModel.useSuggestedPromptItem(prompt)
                    }
                }
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Chat List
    
    private var chatListView: some View {
        Group {
            if viewModel.messageSearchText.isEmpty {
                // 日付セクションでのグループ化
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(viewModel.groupedMessages) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.date.formatted(.dateTime.day().month().weekday().year()))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    
                                    ForEach(group.messages) { message in
                                        MessageBubble(message: message, viewModel: viewModel)
                                            .id(message.id)
                                    }
                                }
                                
                                if viewModel.isLoading {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .padding()
                                        Spacer()
                                    }
                                    .id("loading")
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isLoading) {
                        if viewModel.isLoading {
                            withAnimation {
                                proxy.scrollTo("loading", anchor: .bottom)
                            }
                        }
                    }
                }
            } else {
                // 検索モード（日付グループ化なし）
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredMessages) { message in
                                MessageBubble(message: message, viewModel: viewModel)
                                    .id(message.id)
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
                                .id("loading")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.filteredMessages.count) {
                        if let lastMessage = viewModel.filteredMessages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Input Bar
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            // 検索ボタン
            Button {
                // 検索モードの切り替え
                viewModel.messageSearchText = viewModel.messageSearchText.isEmpty ? " " : ""
            } label: {
                Image(systemName: viewModel.messageSearchText.isEmpty ? "magnifyingglass" : "xmark.circle.fill")
                    .foregroundColor(viewModel.messageSearchText.isEmpty ? .secondary : .pink)
            }
            .buttonStyle(.plain)
            
            TextField("メッセージを入力...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .onSubmit {
                    Task {
                        await viewModel.sendMessage()
                    }
                }
            
            Button {
                Task {
                    await viewModel.sendMessage()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(8)
                } else {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.gray
                                : Color.pink
                        )
                        .cornerRadius(8)
                }
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: -2)
    }
}

// MARK: - Category Filter Button

struct CategoryFilterButton: View {
    let category: PromptCategory
    @ObservedObject var viewModel: AIChatViewModel
    
    var body: some View {
        Button {
            withAnimation {
                viewModel.selectedPromptCategory = viewModel.selectedPromptCategory == category ? nil : category
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(viewModel.selectedPromptCategory == category ? Color.pink : Color(.systemGray5))
            .foregroundColor(viewModel.selectedPromptCategory == category ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

// MARK: - All Prompts Button

struct AllPromptsButton: View {
    @ObservedObject var viewModel: AIChatViewModel
    
    var body: some View {
        Button {
            withAnimation {
                viewModel.selectedPromptCategory = nil
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.caption)
                Text("すべて")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(viewModel.selectedPromptCategory == nil ? Color.pink : Color(.systemGray5))
            .foregroundColor(viewModel.selectedPromptCategory == nil ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessageData
    let viewModel: AIChatViewModel
    @State private var showingMenu = false
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(message.isUser ? Color.pink : Color(.systemGray6))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                    .contextMenu {
                        Button {
                            viewModel.copyMessage(message)
                        } label: {
                            Label("コピー", systemImage: "doc.on.doc")
                        }
                        
                        Button {
                            viewModel.shareMessage(message)
                        } label: {
                            Label("共有", systemImage: "square.and.arrow.up")
                        }
                        
                        if !message.isUser {
                            Button {
                                Task {
                                    await viewModel.regenerateResponse(for: message)
                                }
                            } label: {
                                Label("再生成", systemImage: "arrow.clockwise")
                            }
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            viewModel.prepareDeleteMessage(message)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser { Spacer() }
        }
    }
}

// MARK: - Suggested Prompt Button

struct SuggestedPromptButton: View {
    let prompt: SuggestedPrompt
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: prompt.icon)
                    .foregroundColor(.pink)
                    .frame(width: 20)
                Text(prompt.text)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    AIChatView()
}
