//
//  DayLogRow.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// 日付ごとの学習ログ行
///
/// 統計詳細シート内で1つの学習ログを表示する行
struct DayLogRow: View {
    let log: LearningLog
    @Environment(\.locale) var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // タイトルとカテゴリ
            HStack {
                Text(log.title)
                    .font(.headline)
                Spacer()
                Text(log.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(log.category.color.opacity(0.2))
                    .foregroundColor(log.category.color)
                    .cornerRadius(8)
            }

            // 説明
            Text(log.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // スキルとメタデータ
            HStack {
                if !log.skills.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text(log.skills.map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                    }
                }

                Spacer()

                Text(formatTime(log.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(log.title)、\(log.category.rawValue)")
        .accessibilityHint("学習ログの詳細")
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = locale
        return formatter.string(from: date)
    }
}
