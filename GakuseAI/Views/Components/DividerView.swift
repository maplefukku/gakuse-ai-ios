//
//  DividerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// MARK: - Divider View

/// 区切り線コンポーネント
///
/// - 複数のスタイル: standard, dashed, dotted, minimal
/// - カスタマイズ可能な色、太さ、パディング
/// - テキスト付き区切り線
public struct DividerView: View {
    private let style: DividerStyle
    private let color: Color
    private let thickness: CGFloat
    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat
    private let text: String?
    private let textColor: Color?
    
    public enum DividerStyle {
        case standard
        case dashed
        case dotted
        case minimal
    }
    
    /// 区切り線ビューを初期化
    /// - Parameters:
    ///   - style: 区切り線のスタイル（デフォルト: standard）
    ///   - color: 区切り線の色（デフォルト: グレー）
    ///   - thickness: 区切り線の太さ（デフォルト: 1）
    ///   - horizontalPadding: 水平方向のパディング（デフォルト: 16）
    ///   - verticalPadding: 垂直方向のパディング（デフォルト: 0）
    ///   - text: テキスト（オプション）
    ///   - textColor: テキストの色（オプション）
    public init(
        style: DividerStyle = .standard,
        color: Color = Color(.separator),
        thickness: CGFloat = 1,
        horizontalPadding: CGFloat = 16,
        verticalPadding: CGFloat = 0,
        text: String? = nil,
        textColor: Color? = nil
    ) {
        self.style = style
        self.color = color
        self.thickness = thickness
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.text = text
        self.textColor = textColor
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            if let text = text {
                textDivider(for: text)
            } else {
                simpleDivider
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .drawingGroup()
        .accessibilityElement()
        .accessibilityLabel(text ?? "区切り線")
        .accessibility(hidden: text == nil)
    }
    
    // MARK: - Simple Divider
    
    @ViewBuilder
    private var simpleDivider: some View {
        dividerLine
    }
    
    // MARK: - Text Divider
    
    @ViewBuilder
    private func textDivider(for text: String) -> some View {
        HStack(spacing: 12) {
            dividerLine
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(textColor ?? .secondary)
            
            dividerLine
        }
    }
    
    // MARK: - Divider Line
    
    @ViewBuilder
    private var dividerLine: some View {
        lineView
            .frame(height: thickness)
    }
    
    @ViewBuilder
    private var lineView: some View {
        switch style {
        case .standard:
            standardLine
        case .dashed:
            dashedLine
        case .dotted:
            dottedLine
        case .minimal:
            minimalLine
        }
    }
    
    // MARK: - Line Styles
    
    @ViewBuilder
    private var standardLine: some View {
        Rectangle()
            .fill(color)
    }
    
    @ViewBuilder
    private var dashedLine: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let dashLength: CGFloat = 6
                let gapLength: CGFloat = 4
                let totalLength = dashLength + gapLength
                
                var x: CGFloat = 0
                while x < width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: min(x + dashLength, width), y: 0))
                    x += totalLength
                }
            }
            .stroke(color, lineWidth: thickness)
        }
        .frame(height: thickness)
    }
    
    @ViewBuilder
    private var dottedLine: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let dotRadius: CGFloat = thickness / 2
                let gapLength: CGFloat = 8
                let totalLength = dotRadius * 2 + gapLength
                
                var x: CGFloat = dotRadius
                while x < width {
                    path.move(to: CGPoint(x: x, y: dotRadius))
                    path.addArc(
                        center: CGPoint(x: x, y: dotRadius),
                        radius: dotRadius,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360),
                        clockwise: true
                    )
                    x += totalLength
                }
            }
            .fill(color)
        }
        .frame(height: thickness * 2)
    }
    
    @ViewBuilder
    private var minimalLine: some View {
        Rectangle()
            .fill(color.opacity(0.5))
            .frame(height: 0.5)
    }
}

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


