//
//  StatisticsStatCard.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// 統計ステータスカード
///
/// 統計画面の概要セクションで使用するカードコンポーネント
struct StatisticsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}
