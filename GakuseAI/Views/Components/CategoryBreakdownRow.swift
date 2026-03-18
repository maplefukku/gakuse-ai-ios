//
//  CategoryBreakdownRow.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// カテゴリ詳細行
struct CategoryBreakdownRow: View {
    let category: LearningCategory
    let count: Int
    @State private var isPressed = false

    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(.pink)
                .frame(width: 24)

            Text(category.rawValue)
                .font(.subheadline)

            Spacer()

            Text("\(count)")
                .font(.headline)
                .foregroundColor(.pink)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}
