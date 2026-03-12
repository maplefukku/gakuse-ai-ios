//
//  SuggestedPromptButton.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// 推奨プロンプトボタン
///
/// AI壁打ちチャット画面で推奨されるプロンプトを表示するボタン
struct SuggestedPromptButton: View {
    let prompt: SuggestedPrompt
    let action: () -> Void
    @State private var isPressed = false

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
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .shadow(
                color: isPressed ? .clear : .black.opacity(0.05),
                radius: 4,
                x: 0,
                y: 2
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .foregroundColor(.primary)
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}
