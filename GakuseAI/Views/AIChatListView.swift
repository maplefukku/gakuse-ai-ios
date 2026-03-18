import SwiftUI

struct AIChatListView: View {
    @ObservedObject var viewModel: AIChatViewModel

    var body: some View {
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
}
