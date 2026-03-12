//
//  CategoryStatRow.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// カテゴリ統計行
///
/// 統計画面のカテゴリ分析セクションで使用する行コンポーネント
struct CategoryStatRow: View {
    let item: CategoryDataPoint
    @State private var isPressed = false

    var body: some View {
        HStack {
            Circle()
                .fill(item.color)
                .frame(width: 12, height: 12)

            Text(item.category.rawValue)
                .font(.subheadline)

            Spacer()

            Text("\(item.count)")
                .font(.headline)
                .foregroundColor(.pink)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}
