//
//  PortfolioLogCard.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// ポートフォリオログカード
struct PortfolioLogCard: View {
    let log: LearningLog
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: log.category.icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.pink)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(log.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(log.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(log.title)、\(log.category.rawValue)")
        .accessibilityHint("詳細を表示")
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}
