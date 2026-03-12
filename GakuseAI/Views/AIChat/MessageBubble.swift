//
//  MessageBubble.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// メッセージバブル
///
/// AI壁打ちチャット画面でメッセージを表示するバブルコンポーネント
struct MessageBubble: View {
    let message: ChatMessageData
    let viewModel: AIChatViewModel
    @State private var showingMenu = false
    @State private var isPressed = false

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
                    .scaleEffect(showingMenu ? 1.05 : (isPressed ? 0.98 : 1.0))
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showingMenu)
                    .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                        withAnimation {
                            isPressed = pressing
                        }
                    }, perform: {})
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
