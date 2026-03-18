import SwiftUI

struct AIChatInputBar: View {
    @ObservedObject var viewModel: AIChatViewModel

    var body: some View {
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
