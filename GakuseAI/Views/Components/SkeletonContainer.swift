//
//  SkeletonContainer.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

// MARK: - SkeletonContainer
/// コンテンツ全体をスケルトンで覆うラッパー
public struct SkeletonContainer<Content: View>: View {
    private let isLoading: Bool
    private let style: SkeletonView.SkeletonStyle
    private let content: Content

    public init(
        isLoading: Bool,
        style: SkeletonView.SkeletonStyle = .shimmer,
        @ViewBuilder content: () -> Content
    ) {
        self.isLoading = isLoading
        self.style = style
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
                .opacity(isLoading ? 0 : 1)
                .disabled(isLoading)

            if isLoading {
                content
                    .redacted(reason: .placeholder)
                    .overlay {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                    }
            }
        }
        .drawingGroup()
    }
}
