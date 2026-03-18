//
//  SectionDividerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

// MARK: - Section Divider

/// セクション区切り線（太い、余白多め）
public struct SectionDividerView: View {
    private let title: String?
    private let color: Color

    public init(title: String? = nil, color: Color = Color(.separator)) {
        self.title = title
        self.color = color
    }

    public var body: some View {
        VStack(spacing: 8) {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }

            DividerView(
                style: .standard,
                color: color,
                thickness: 1.5,
                horizontalPadding: 0,
                verticalPadding: 8
            )
        }
        .drawingGroup()
    }
}
