//
//  StatisticsStatCard.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-17.
//

import SwiftUI

/// 統計カードコンポーネント
struct StatisticsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title.bold())
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    VStack(spacing: 16) {
        StatisticsStatCard(
            title: "総ログ数",
            value: "128",
            icon: "book.fill",
            color: .pink
        )

        StatisticsStatCard(
            title: "総スキル数",
            value: "24",
            icon: "star.fill",
            color: .orange
        )
    }
    .padding()
}
