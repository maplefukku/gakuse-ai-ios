import SwiftUI

struct AIChatEmptyState: View {
    @ObservedObject var viewModel: AIChatViewModel

    var body: some View {
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
}
