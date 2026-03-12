//
//  AllPromptsButton.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// 全プロンプトボタン
///
/// AI壁打ちチャット画面ですべてのプロンプトを表示するボタン
struct AllPromptsButton: View {
    @ObservedObject var viewModel: AIChatViewModel
    @State private var isPressed = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
            .background(
                viewModel.selectedPromptCategory == nil
                    ? Color.pink
                    : Color(.systemGray5)
            )
            .foregroundColor(
                viewModel.selectedPromptCategory == nil
                    ? .white
                    : .primary
            )
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}
