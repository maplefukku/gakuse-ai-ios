//
//  SignUpTermsView.swift
//  GakuseAI
//
//  Created by OpenGoat on 2026-03-16.
//

import SwiftUI

// MARK: - SignUpTermsView
/// 新規登録の利用規約表示コンポーネント
public struct SignUpTermsView: View {
    @Binding private var showingTerms: Bool
    @State private var isPressed: Bool = false

    public init(showingTerms: Binding<Bool>) {
        self._showingTerms = showingTerms
    }

    public var body: some View {
        VStack(spacing: 8) {
            Text("アカウントを作成することで、以下に同意したことになります：")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 4) {
                Button {
                    showingTerms = true
                } label: {
                    Text("利用規約")
                        .font(.caption)
                        .underline()
                        .foregroundColor(.pink)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                    withAnimation {
                        isPressed = pressing
                    }
                }, perform: {})

                Text("と")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button {
                    showingTerms = true
                } label: {
                    Text("プライバシーポリシー")
                        .font(.caption)
                        .underline()
                        .foregroundColor(.pink)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                    withAnimation {
                        isPressed = pressing
                    }
                }, perform: {})
            }
        }
        .padding(.top, 8)
    }
}
