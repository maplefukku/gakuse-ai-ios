//
//  VerticalDividerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

// MARK: - Vertical Divider

/// 垂直区切り線
public struct VerticalDividerView: View {
    private let style: DividerView.DividerStyle
    private let color: Color
    private let thickness: CGFloat
    private let verticalPadding: CGFloat
    private let horizontalPadding: CGFloat

    public init(
        style: DividerView.DividerStyle = .standard,
        color: Color = Color(.separator),
        thickness: CGFloat = 1,
        verticalPadding: CGFloat = 16,
        horizontalPadding: CGFloat = 0
    ) {
        self.style = style
        self.color = color
        self.thickness = thickness
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
    }

    public var body: some View {
        dividerLine
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .drawingGroup()
    }

    @ViewBuilder
    private var dividerLine: some View {
        lineView
            .frame(width: thickness)
    }

    @ViewBuilder
    private var lineView: some View {
        switch style {
        case .standard:
            Rectangle()
                .fill(color)
        case .dashed:
            GeometryReader { geometry in
                Path { path in
                    let height = geometry.size.height
                    let dashLength: CGFloat = 6
                    let gapLength: CGFloat = 4
                    let totalLength = dashLength + gapLength

                    var y: CGFloat = 0
                    while y < height {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: 0, y: min(y + dashLength, height)))
                        y += totalLength
                    }
                }
                .stroke(color, lineWidth: thickness)
            }
            .frame(width: thickness)
        case .dotted:
            GeometryReader { geometry in
                Path { path in
                    let height = geometry.size.height
                    let dotRadius: CGFloat = thickness / 2
                    let gapLength: CGFloat = 8
                    let totalLength = dotRadius * 2 + gapLength

                    var y: CGFloat = dotRadius
                    while y < height {
                        path.move(to: CGPoint(x: dotRadius, y: y))
                        path.addArc(
                            center: CGPoint(x: dotRadius, y: y),
                            radius: dotRadius,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360),
                            clockwise: true
                        )
                        y += totalLength
                    }
                }
                .fill(color)
            }
            .frame(width: thickness * 2)
        case .minimal:
            Rectangle()
                .fill(color.opacity(0.5))
                .frame(width: 0.5)
        }
    }
}
