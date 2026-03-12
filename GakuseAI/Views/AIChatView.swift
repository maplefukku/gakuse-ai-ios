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
        }
        .drawingGroup() // パフォーマンス最適化: レイヤー合成をまとめる
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
                                            .transition(.asymmetric(
                                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                                removal: .scale(scale: 0.9).combined(with: .opacity)
                                            ))
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
                    .drawingGroup() // パフォーマンス改善: レイヤー合成を最適化
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
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .scale(scale: 0.9).combined(with: .opacity)
                                    ))
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
                    .drawingGroup() // パフォーマンス改善: レイヤー合成を最適化
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
                        .scaleEffect(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 1.0 : 1.1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.inputText)
                }
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: -2)
    }
}

#Preview {
    AIChatView()
}
