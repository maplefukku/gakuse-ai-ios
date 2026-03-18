//
//  SkeletonGrid.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-14.
//

import SwiftUI

/// グリッド形式のスケルトンビュー
public struct SkeletonGrid: View {
    private let columns: Int
    private let rows: Int
    private let style: SkeletonView.SkeletonStyle
    private let spacing: CGFloat

    public init(
        columns: Int = 2,
        rows: Int = 3,
        style: SkeletonView.SkeletonStyle = .shimmer,
        spacing: CGFloat = 16
    ) {
        self.columns = columns
        self.rows = rows
        self.style = style
        self.spacing = spacing
    }

    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            ForEach(0..<(columns * rows), id: \.self) { _ in
                SkeletonCard(style: style)
            }
        }
        .padding(16)
        .drawingGroup()
        .accessibilityElement()
        .accessibilityLabel("ロード中")
        .accessibility(hidden: true)
    }
}
