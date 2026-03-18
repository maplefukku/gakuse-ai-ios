//
//  DetailPopupSheet.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-17.
//

import SwiftUI

/// 詳細ポップアップシート
struct DetailPopupSheet: View {
    let dataPoint: WeeklyDataPoint
    let allLogs: [LearningLog]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 日付セクション
                    VStack(spacing: 8) {
                        Text(dataPoint.weekday)
                            .font(.title2.bold())
                        Text(formatDate(dataPoint.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 16)

                    Divider()

                    // ログ一覧セクション
                    VStack(alignment: .leading, spacing: 12) {
                        Text("学習ログ")
                            .font(.headline)

                        if filteredLogs.isEmpty {
                            Text("ログがありません")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(filteredLogs) { log in
                                LogSummaryCard(log: log)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        // シートは親ビューで制御
                    }
                }
            }
        }
    }

    private var filteredLogs: [LearningLog] {
        allLogs.filter { log in
            Calendar.current.isDate(log.createdAt, inSameDayAs: dataPoint.date)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

/// ログサマリーカード
struct LogSummaryCard: View {
    let log: LearningLog

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(log.title)
                .font(.subheadline.bold())

            Text(log.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if !log.skills.isEmpty {
                HStack(spacing: 4) {
                    ForEach(log.skills.prefix(3), id: \.self) { skill in
                        Text(skill.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }

                    if log.skills.count > 3 {
                        Text("+\(log.skills.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    DetailPopupSheet(
        dataPoint: WeeklyDataPoint(
            date: Date(),
            count: 3,
            weekday: "月"
        ),
        allLogs: [
            LearningLog(
                id: UUID(),
                title: "SwiftUI学習",
                description: "SwiftUIの基本を学習",
                category: .programming,
                isPublic: true,
                createdAt: Date(),
                updatedAt: Date(),
                skills: [
                    Skill(name: "SwiftUI", level: .intermediate),
                    Skill(name: "Swift", level: .advanced)
                ],
                reflections: []
            )
        ]
    )
}
