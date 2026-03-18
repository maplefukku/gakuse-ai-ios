//
//  SkeletonCard.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-14.
//

import SwiftUI

/// カード形式のスケルトンビュー
public struct SkeletonCard: View {
    private let width: CGFloat?
    private let height: CGFloat
    private let style: SkeletonView.SkeletonStyle
    private let hasAvatar: Bool
    private let hasImage: Bool

    public init(
        width: CGFloat? = nil,
        height: CGFloat = 120,
        style: SkeletonView.SkeletonStyle = .shimmer,
        hasAvatar: Bool = true,
        hasImage: Bool = false
    ) {
        self.width = width
        self.height = height
        self.style = style
        self.hasAvatar = hasAvatar
        self.hasImage = hasImage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if hasImage {
                SkeletonView(width: .infinity, height: 80, style: style)
            }

            HStack(spacing: 12) {
                if hasAvatar {
                    SkeletonView(width: 40, height: 40, cornerRadius: 20, style: style)
                }

                VStack(alignment: .leading, spacing: 8) {
                    SkeletonView(width: 120, height: 12, cornerRadius: 6, style: style)
                    SkeletonView(width: 80, height: 10, cornerRadius: 5, style: style)
                }

                Spacer()
            }

            SkeletonView(width: .infinity, height: 10, cornerRadius: 5, style: style)
            SkeletonView(width: 180, height: 10, cornerRadius: 5, style: style)
        }
        .padding(16)
        .frame(width: width)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .drawingGroup()
        .accessibilityElement()
        .accessibilityLabel("ロード中")
        .accessibility(hidden: true)
    }
}
