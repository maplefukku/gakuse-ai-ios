//
//  AccordionView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-09.
//

import SwiftUI

// MARK: - AccordionItem

/// アコーディオンの各アイテムを表すモデル
public struct AccordionItem: Identifiable {
    public let id = UUID()
    let title: String
    let subtitle: String?
    let icon: String?
    let content: AnyView
    
    public init<T: View>(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        @ViewBuilder content: () -> T
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.content = AnyView(content())
    }
}

// MARK: - AccordionView

/// アコーディオンスタイルの展開可能なリストビュー
public struct AccordionView: View {
    @State private var expandedItemIds: Set<UUID> = []
    
    private let items: [AccordionItem]
    private let style: AccordionStyle
    private let allowMultipleExpanded: Bool
    private let animationDuration: Double
    
    public enum AccordionStyle {
        case standard
        case elevated
        case outlined
        case minimal
    }
    
    /// アコーディオンビューを初期化
    /// - Parameters:
    ///   - items: アコーディオンアイテムの配列
    ///   - style: アコーディオンのスタイル（デフォルト: standard）
    ///   - allowMultipleExpanded: 複数のアイテムを展開可能にするか（デフォルト: false）
    ///   - animationDuration: 展開アニメーションの長さ（秒）
    public init(
        items: [AccordionItem],
        style: AccordionStyle = .standard,
        allowMultipleExpanded: Bool = false,
        animationDuration: Double = 0.3
    ) {
        self.items = items
        self.style = style
        self.allowMultipleExpanded = allowMultipleExpanded
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                AccordionRow(
                    item: item,
                    isExpanded: expandedItemIds.contains(item.id),
                    style: style,
                    animationDuration: animationDuration
                ) {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        toggleExpand(item.id)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        toggleExpand(item.id)
                    }
                }
                
                if expandedItemIds.contains(item.id) {
                    item.content
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(style == .outlined ? 16 : 12)
                        .background(
                            Group {
                                switch style {
                                case .standard:
                                    Color.clear
                                case .elevated:
                                    Color.gray.opacity(0.05)
                                case .outlined:
                                    Color.clear
                                case .minimal:
                                    Color.clear
                                }
                            }
                        )
                        .drawingGroup()
                }
                
                // アイテム間の区切り線（最後のアイテム以外）
                if item.id != items.last?.id {
                    divider
                }
            }
        }
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(border)
        .shadow(shadowRadius > 0 ? 2 : 0)
        .drawingGroup()
    }
    
    private var backgroundColor: Color {
        switch style {
        case .standard:
            Color(.systemBackground)
        case .elevated:
            Color(.systemBackground)
        case .outlined:
            Color.clear
        case .minimal:
            Color.clear
        }
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case .standard:
            12
        case .elevated:
            12
        case .outlined:
            12
        case .minimal:
            0
        }
    }
    
    @ViewBuilder
    private var border: some View {
        switch style {
        case .outlined:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        default:
            EmptyView()
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .elevated:
            8
        default:
            0
        }
    }
    
    @ViewBuilder
    private var divider: some View {
        if style != .outlined {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, style == .standard ? 16 : 12)
        }
    }
    
    private func toggleExpand(_ id: UUID) {
        if expandedItemIds.contains(id) {
            expandedItemIds.remove(id)
        } else {
            if allowMultipleExpanded {
                expandedItemIds.insert(id)
            } else {
                expandedItemIds = [id]
            }
        }
    }
}

// MARK: - AccordionRow

private struct AccordionRow: View {
    let item: AccordionItem
    let isExpanded: Bool
    let style: AccordionView.AccordionStyle
    let animationDuration: Double
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // アイコン
            if let icon = item.icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.15))
                    )
            }
            
            // タイトルとサブタイトル
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 展開インジケーター
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(isExpanded ? 0 : 0))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(backgroundColor)
        .drawingGroup()
    }
    
    private var backgroundColor: Color {
        switch style {
        case .standard:
            Color.clear
        case .elevated:
            Color.clear
        case .outlined:
            isExpanded ? Color.gray.opacity(0.05) : Color.clear
        case .minimal:
            Color.clear
        }
    }
    
    private var iconColor: Color {
        switch style {
        case .standard:
            .blue
        case .elevated:
            .purple
        case .outlined:
            .green
        case .minimal:
            .primary
        }
    }
}

// MARK: - CompactAccordionView

/// コンパクトなアコーディオンビュー（サブタイトルなし、アイコンなし）
public struct CompactAccordionView: View {
    @State private var expandedItemIds: Set<UUID> = []
    
    private let items: [AccordionItem]
    private let allowMultipleExpanded: Bool
    private let animationDuration: Double
    
    public init(
        items: [AccordionItem],
        allowMultipleExpanded: Bool = false,
        animationDuration: Double = 0.25
    ) {
        self.items = items
        self.allowMultipleExpanded = allowMultipleExpanded
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        VStack(spacing: 1) {
            ForEach(items) { item in
                VStack(spacing: 0) {
                    HStack {
                        Text(item.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: expandedItemIds.contains(item.id) ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .drawingGroup()
                    
                    if expandedItemIds.contains(item.id) {
                        item.content
                            .padding(12)
                            .transition(.opacity)
                            .drawingGroup()
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        toggleExpand(item.id)
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .drawingGroup()
    }
    
    private func toggleExpand(_ id: UUID) {
        if expandedItemIds.contains(id) {
            expandedItemIds.remove(id)
        } else {
            if allowMultipleExpanded {
                expandedItemIds.insert(id)
            } else {
                expandedItemIds = [id]
            }
        }
    }
}

// MARK: - Previews

#Preview("Standard Style") {
    AccordionView(items: [
        AccordionItem(
            title: "学習ログ",
            subtitle: "3件のログ",
            icon: "book.fill"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text("• SwiftUIの基礎")
                Text("• MVVMアーキテクチャ")
                Text("• Combineフレームワーク")
            }
            .font(.system(size: 14))
        },
        AccordionItem(
            title: "プロジェクト",
            subtitle: "2件のプロジェクト",
            icon: "folder.fill"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text("• To-Doアプリ")
                Text("• 天気予報アプリ")
            }
            .font(.system(size: 14))
        },
        AccordionItem(
            title: "設定",
            icon: "gearshape.fill"
        ) {
            Text("設定オプション")
                .font(.system(size: 14))
        }
    ])
    .padding()
}

#Preview("Elevated Style") {
    AccordionView(
        items: [
            AccordionItem(
                title: "高度な機能",
                subtitle: "展開して詳細を見る",
                icon: "star.fill"
            ) {
                Text("高度な機能のコンテンツ")
            }
        ],
        style: .elevated
    )
    .padding()
}

#Preview("Outlined Style") {
    AccordionView(
        items: [
            AccordionItem(
                title: "アウトラインスタイル",
                subtitle: "境界線付き",
                icon: "square.dashed"
            ) {
                Text("アウトラインスタイルのコンテンツ")
            }
        ],
        style: .outlined
    )
    .padding()
}

#Preview("Minimal Style") {
    AccordionView(
        items: [
            AccordionItem(
                title: "ミニマルスタイル",
                subtitle: "シンプルなデザイン",
                icon: "line.horizontal.3"
            ) {
                Text("ミニマルスタイルのコンテンツ")
            }
        ],
        style: .minimal
    )
    .padding()
}

#Preview("Compact Accordion") {
    CompactAccordionView(items: [
        AccordionItem(title: "アイテム1") {
            Text("コンテンツ1")
        },
        AccordionItem(title: "アイテム2") {
            Text("コンテンツ2")
        }
    ])
    .padding()
}

#Preview("Multiple Expanded") {
    AccordionView(
        items: [
            AccordionItem(title: "複数展開可能1", icon: "1.circle.fill") {
                Text("コンテンツ1")
            },
            AccordionItem(title: "複数展開可能2", icon: "2.circle.fill") {
                Text("コンテンツ2")
            },
            AccordionItem(title: "複数展開可能3", icon: "3.circle.fill") {
                Text("コンテンツ3")
            }
        ],
        allowMultipleExpanded: true
    )
    .padding()
}
