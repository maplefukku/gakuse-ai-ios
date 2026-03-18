//
//  SkeletonList.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-14.
//

import SwiftUI

/// リスト形式のスケルトンビュー
public struct SkeletonList: View {
    private let rowCount: Int
    private let style: SkeletonView.SkeletonStyle
    private let hasAvatar: Bool

    public init(
        rowCount: Int = 5,
        style: SkeletonView.SkeletonStyle = .shimmer,
        hasAvatar: Bool = true
    ) {
        self.rowCount = rowCount
        self.style = style
        self.hasAvatar = hasAvatar
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { index in
                SkeletonRow(hasAvatar: hasAvatar, style: style)

                if index < rowCount - 1 {
                    Divider()
                        .background(Color.secondary.opacity(0.2))
                }
            }
        }
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .drawingGroup()
        .accessibilityElement()
        .accessibilityLabel("ロード中")
        .accessibility(hidden: true)
    }
}
