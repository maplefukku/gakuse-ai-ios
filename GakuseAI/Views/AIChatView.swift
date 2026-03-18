import SwiftUI

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.messages.isEmpty {
                    AIChatEmptyState(viewModel: viewModel)
                } else {
                    AIChatListView(viewModel: viewModel)
                }

                AIChatInputBar(viewModel: viewModel)
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
}
