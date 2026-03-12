//
//  CategoryFilterButton.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// カテゴリフィルターボタン
///
/// AI壁打ちチャット画面でプロンプトカテゴリをフィルターするボタン
struct CategoryFilterButton: View {
    let category: PromptCategory
    @ObservedObject var viewModel: AIChatViewModel
    @State private var isPressed = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
            .background(
                viewModel.selectedPromptCategory == category
                    ? Color.pink
                    : Color(.systemGray5)
            )
            .foregroundColor(
                viewModel.selectedPromptCategory == category
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
