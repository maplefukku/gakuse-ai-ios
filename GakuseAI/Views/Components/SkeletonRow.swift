//
//  SkeletonRow.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-14.
//

import SwiftUI

/// リスト行形式のスケルトンビュー
public struct SkeletonRow: View {
    private let hasAvatar: Bool
    private let hasIcon: Bool
    private let style: SkeletonView.SkeletonStyle

    public init(
        hasAvatar: Bool = true,
        hasIcon: Bool = false,
        style: SkeletonView.SkeletonStyle = .shimmer
    ) {
        self.hasAvatar = hasAvatar
        self.hasIcon = hasIcon
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 12) {
            if hasAvatar {
                SkeletonView(width: 40, height: 40, cornerRadius: 20, style: style)
            } else if hasIcon {
                SkeletonView(width: 32, height: 32, cornerRadius: 8, style: style)
            }

            VStack(alignment: .leading, spacing: 8) {
                SkeletonView(width: 140, height: 12, cornerRadius: 6, style: style)
                SkeletonView(width: 200, height: 10, cornerRadius: 5, style: style)
            }

            Spacer()

            SkeletonView(width: 24, height: 24, cornerRadius: 12, style: style)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .drawingGroup()
        .accessibilityElement()
        .accessibilityLabel("ロード中")
        .accessibility(hidden: true)
    }
}
