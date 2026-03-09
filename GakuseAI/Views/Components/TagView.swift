//
//  TagView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// MARK: - Tag View

/// タグを表示する汎用コンポーネント
///
/// - 複数のスタイル: standard, pill, minimal, outlined
/// - カスタマイズ可能なタイトル、色、サイズ
/// - 削除ボタン付き
public struct TagView: View {
    private let title: String
    private let style: TagStyle
    private let color: Color
    private let size: TagSize
    private let isRemovable: Bool
    private let onTap: (() -> Void)?
    private let onRemove: (() -> Void)?
    
    @State private var isPressed: Bool = false
    
    public enum TagStyle {
        case standard
        case pill
        case minimal
        case outlined
    }
    
    public enum TagSize {
        case small
        case medium
        case large
    }
    
    /// タグビューを初期化
    /// - Parameters:
    ///   - title: タグのタイトル
    ///   - style: タグのスタイル（デフォルト: standard）
    ///   - color: タグの色（デフォルト: 青）
    ///   - size: タグのサイズ（デフォルト: medium）
    ///   - isRemovable: 削除可能かどうか（デフォルト: false）
    ///   - onTap: タップ時のアクション
    ///   - onRemove: 削除時のアクション
    public init(
        title: String,
        style: TagStyle = .standard,
        color: Color = .blue,
        size: TagSize = .medium,
        isRemovable: Bool = false,
        onTap: (() -> Void)? = nil,
        onRemove: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.color = color
        self.size = size
        self.isRemovable = isRemovable
        self.onTap = onTap
        self.onRemove = onRemove
    }
    
    public var body: some View {
        tagContent
            .drawingGroup()
    }
    
    @ViewBuilder
    private var tagContent: some View {
        HStack(spacing: size == .small ? 4 : 6) {
            Text(title)
                .font(font)
                .foregroundColor(textColor)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .background(backgroundColor)
                .overlay(border)
                .clipShape(shape)
            
            if isRemovable, let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: fontSize(for: .caption)))
                        .foregroundColor(removeButtonColor)
                        .frame(width: 16, height: 16)
                        .background(Circle().fill(removeButtonBackgroundColor))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            onTap?()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
    
    // MARK: - Font
    
    private var font: Font {
        switch size {
        case .small:
            .system(size: 11, weight: .medium)
        case .medium:
            .system(size: 13, weight: .medium)
        case .large:
            .system(size: 15, weight: .semibold)
        }
    }
    
    private func fontSize(for style: Font.TextStyle) -> CGFloat {
        switch size {
        case .small:
            return 10
        case .medium:
            return 12
        case .large:
            return 14
        }
    }
    
    // MARK: - Padding
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small:
            return 8
        case .medium:
            return 10
        case .large:
            return 12
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small:
            return 4
        case .medium:
            return 6
        case .large:
            return 8
        }
    }
    
    // MARK: - Background
    
    private var backgroundColor: Color {
        switch style {
        case .standard:
            color.opacity(0.15)
        case .pill:
            color.opacity(0.1)
        case .minimal:
            Color.clear
        case .outlined:
            Color.clear
        }
    }
    
    // MARK: - Text Color
    
    private var textColor: Color {
        switch style {
        case .standard:
            color
        case .pill:
            color
        case .minimal:
            .primary
        case .outlined:
            color
        }
    }
    
    // MARK: - Border
    
    @ViewBuilder
    private var border: some View {
        if style == .outlined {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color.opacity(0.5), lineWidth: 1)
        }
    }
    
    // MARK: - Shape
    
    private var shape: some Shape {
        RoundedRectangle(cornerRadius: cornerRadius)
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case .standard:
            return 6
        case .pill:
            return .infinity
        case .minimal:
            return 4
        case .outlined:
            return 6
        }
    }
    
    // MARK: - Remove Button
    
    private var removeButtonColor: Color {
        color
    }
    
    private var removeButtonBackgroundColor: Color {
        color.opacity(0.2)
    }
}

// MARK: - Tag Group View

/// 複数のタグをグループ化して表示するビュー
public struct TagGroupView: View {
    private let tags: [Tag]
    private let style: TagView.TagStyle
    private let size: TagView.TagSize
    private let spacing: CGFloat
    private let alignment: HorizontalAlignment
    
    public struct Tag: Identifiable {
        public let id = UUID()
        public let title: String
        public var color: Color
        public var isRemovable: Bool
        
        public init(title: String, color: Color = .blue, isRemovable: Bool = false) {
            self.title = title
            self.color = color
            self.isRemovable = isRemovable
        }
    }
    
    /// タググループビューを初期化
    /// - Parameters:
    ///   - tags: タグの配列
    ///   - style: タグのスタイル（デフォルト: standard）
    ///   - size: タグのサイズ（デフォルト: medium）
    ///   - spacing: タグ間の間隔（デフォルト: 8）
    ///   - alignment: 配置（デフォルト: leading）
    public init(
        tags: [Tag],
        style: TagView.TagStyle = .standard,
        size: TagView.TagSize = .medium,
        spacing: CGFloat = 8,
        alignment: HorizontalAlignment = .leading
    ) {
        self.tags = tags
        self.style = style
        self.size = size
        self.spacing = spacing
        self.alignment = alignment
    }
    
    public var body: some View {
        FlowLayout(spacing: spacing, alignment: alignment) {
            ForEach(tags) { tag in
                TagView(
                    title: tag.title,
                    style: style,
                    color: tag.color,
                    size: size,
                    isRemovable: tag.isRemovable
                )
            }
        }
        .drawingGroup()
    }
}

// MARK: - Flow Layout

/// ラップアラウンドレイアウト（Flow Layout）
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(height, 0))
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        
        for row in rows {
            var x = bounds.minX
            
            if alignment == .center {
                x += (bounds.width - row.width) / 2
            } else if alignment == .trailing {
                x += bounds.width - row.width
            }
            
            for subview in row.subviews {
                subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += subview.dimensions(in: .unspecified).width + spacing
            }
            
            y += row.height + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var currentX: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && !currentRow.subviews.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                currentX = 0
            }
            
            currentRow.subviews.append(subview)
            currentRow.width = max(currentRow.width, currentX + size.width)
            currentRow.height = max(currentRow.height, size.height)
            currentX += size.width + spacing
        }
        
        if !currentRow.subviews.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private struct Row {
        var subviews: [LayoutSubview] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }
}

// MARK: - Previews

#Preview("Standard Style") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Standard Style")
            .font(.headline)
        
        HStack(spacing: 8) {
            TagView(title: "SwiftUI")
            TagView(title: "iOS", color: .blue)
            TagView(title: "Swift", color: .orange)
            TagView(title: "Xcode", color: .purple)
        }
        
        TagView(title: "Removable Tag", color: .green, isRemovable: true)
        
        TagGroupView(
            tags: [
                Tag(title: "Tag 1", color: .blue),
                Tag(title: "Tag 2", color: .green),
                Tag(title: "Tag 3", color: .orange),
                Tag(title: "Tag 4", color: .purple),
                Tag(title: "Tag 5", color: .red)
            ]
        )
    }
    .padding()
}

#Preview("Pill Style") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Pill Style")
            .font(.headline)
        
        HStack(spacing: 8) {
            TagView(title: "SwiftUI", style: .pill)
            TagView(title: "iOS", color: .blue, style: .pill)
            TagView(title: "Swift", color: .orange, style: .pill)
        }
        
        TagGroupView(
            tags: [
                Tag(title: "Tag 1", color: .blue),
                Tag(title: "Tag 2", color: .green),
                Tag(title: "Tag 3", color: .orange)
            ],
            style: .pill
        )
    }
    .padding()
}

#Preview("Minimal Style") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Minimal Style")
            .font(.headline)
        
        HStack(spacing: 8) {
            TagView(title: "SwiftUI", style: .minimal)
            TagView(title: "iOS", style: .minimal)
            TagView(title: "Swift", style: .minimal)
        }
    }
    .padding()
}

#Preview("Outlined Style") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Outlined Style")
            .font(.headline)
        
        HStack(spacing: 8) {
            TagView(title: "SwiftUI", style: .outlined)
            TagView(title: "iOS", color: .blue, style: .outlined)
            TagView(title: "Swift", color: .orange, style: .outlined)
        }
        
        TagView(title: "Removable", style: .outlined, isRemovable: true)
    }
    .padding()
}

#Preview("Size Variants") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Size Variants")
            .font(.headline)
        
        HStack(spacing: 8) {
            TagView(title: "Small", size: .small)
            TagView(title: "Medium", size: .medium)
            TagView(title: "Large", size: .large)
        }
    }
    .padding()
}

#Preview("Tag Group") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Tag Group with Removable Tags")
            .font(.headline)
        
        TagGroupView(
            tags: [
                Tag(title: "SwiftUI", color: .blue, isRemovable: true),
                Tag(title: "iOS", color: .green, isRemovable: true),
                Tag(title: "Swift", color: .orange, isRemovable: true),
                Tag(title: "Xcode", color: .purple, isRemovable: true),
                Tag(title: "Combine", color: .red, isRemovable: true),
                Tag(title: "CoreData", color: .indigo, isRemovable: true)
            ]
        )
    }
    .padding()
}
