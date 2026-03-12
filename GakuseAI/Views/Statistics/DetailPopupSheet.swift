//
//  DetailPopupSheet.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// 統計詳細ポップアップシート
///
/// 選択した週間データポイントの詳細を表示するシート
struct DetailPopupSheet: View {
    let dataPoint: WeeklyDataPoint
    let allLogs: [LearningLog]
    @Environment(\.locale) var locale
    @Environment(\.dismiss) var dismiss

    private var dayLogs: [LearningLog] {
        let calendar = Calendar.current
        return allLogs.filter { log in
            calendar.isDate(log.createdAt, inSameDayAs: dataPoint.date)
        }.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 日付と件数
                    VStack(alignment: .leading, spacing: 8) {
                        Text(formatDate(dataPoint.date))
                            .font(.title2.bold())
                        Text(dataPoint.weekday)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack(spacing: 8) {
                            Image(systemName: "doc.fill")
                            Text("\(dataPoint.count) 件の学習ログ")
                                .font(.headline)
                                .foregroundColor(.pink)
                        }
                    }
                    .padding(.vertical)

                    Divider()

                    // 学習ログリスト
                    if dayLogs.isEmpty {
                        Text("ログがありません")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(dayLogs) { log in
                                DayLogRow(log: log)
                                Divider()
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
                        dismiss()
                    }
                    .accessibilityLabel("詳細を閉じる")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(formatDate(dataPoint.date))の学習ログ詳細")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = locale
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = locale
        return formatter.string(from: date)
    }
}
