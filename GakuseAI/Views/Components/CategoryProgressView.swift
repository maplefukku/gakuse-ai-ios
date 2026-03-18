//
//  CategoryProgressView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

// MARK: - Category Progress View

/// カテゴリ別セグメントプログレスビュー
public struct CategoryProgressView: View {
    private let categories: [Category]
    private let style: SegmentedProgressView.SegmentedProgressStyle

    public struct Category: Identifiable {
        public let id = UUID()
        public let name: String
        public let value: Double
        public let color: Color
    }

    public init(
        categories: [Category],
        style: SegmentedProgressView.SegmentedProgressStyle = .standard
    ) {
        self.categories = categories
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("カテゴリ別進捗")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            SegmentedProgressView(
                segments: categories.map { category in
                    SegmentedProgressView.Segment(
                        value: category.value,
                        color: category.color,
                        label: category.name
                    )
                },
                style: style,
                showLabels: true
            )

            categoryList
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .drawingGroup()
    }

    @ViewBuilder
    private var categoryList: some View {
        VStack(spacing: 12) {
            ForEach(categories) { category in
                HStack {
                    Circle()
                        .fill(category.color)
                        .frame(width: 12, height: 12)

                    Text(category.name)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(Int(category.value))%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
