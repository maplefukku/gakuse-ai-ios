//
//  CategoryStatRow.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-17.
//

import SwiftUI

/// カテゴリ統計行
struct CategoryStatRow: View {
    let item: CategoryDataPoint

    var body: some View {
        HStack {
            Circle()
                .fill(item.color)
                .frame(width: 12, height: 12)

            Text(item.category.rawValue)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Text("\(item.count)")
                .font(.body.bold())
                .foregroundColor(.primary)

            let percentage = item.totalCount > 0 ? Double(item.count) / Double(item.totalCount) : 0
            Text("(\(Int(percentage * 100))%)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
    }
}

extension CategoryDataPoint {
    var totalCount: Int {
        return count
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        CategoryStatRow(item: CategoryDataPoint(
            category: .programming,
            count: 42,
            color: .blue
        ))

        CategoryStatRow(item: CategoryDataPoint(
            category: .language,
            count: 28,
            color: .green
        ))
    }
    .padding()
}
