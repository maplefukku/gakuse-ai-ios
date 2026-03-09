//
//  MenuView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//  Copyright © 2026 GakuseAI. All rights reserved.
//

import SwiftUI

/// ドロップダウンメニューを表示する汎用コンポーネント
///
/// - 複数のスタイル: standard, minimal, pill
/// - カスタマイズ可能なメニュー項目、アイコン、アクセサリ
/// - SwiftUI標準のMenuと互換性のあるインターフェース
struct MenuView: View {
    // MARK: - Styles
    
    enum Style {
        case standard
        case minimal
        case pill
    }
    
    // MARK: - MenuItem
    
    struct MenuItem: Identifiable, Equatable {
        let id = UUID()
        let icon: String?
        let title: String
        let action: () -> Void
        let isDestructive: Bool
        let isEnabled: Bool
        
        init(
            icon: String? = nil,
            title: String,
            action: @escaping () -> Void,
            isDestructive: Bool = false,
            isEnabled: Bool = true
        ) {
            self.icon = icon
            self.title = title
            self.action = action
            self.isDestructive = isDestructive
            self.isEnabled = isEnabled
        }
        
        static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    // MARK: - Properties
    
    private let items: [MenuItem]
    private let label: () -> AnyView
    private let style: Style
    
    // MARK: - Initialization
    
    /// 基本的なMenuViewを初期化
    init<Label: View>(
        items: [MenuItem],
        style: Style = .standard,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.items = items
        self.style = style
        self.label = { AnyView(label()) }
    }
    
    /// シンプルなテキストラベルを持つMenuViewを初期化
    init(
        title: String,
        items: [MenuItem],
        style: Style = .standard
    ) {
        self.items = items
        self.style = style
        self.label = {
            AnyView(
                HStack(spacing: 4) {
                    Text(title)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.primary)
            )
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .drawingGroup()
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        switch style {
        case .standard:
            standardMenu
        case .minimal:
            minimalMenu
        case .pill:
            pillMenu
        }
    }
    
    // MARK: - Style Views
    
    private var standardMenu: some View {
        Menu {
            ForEach(items) { item in
                if item.isEnabled {
                    Button(action: item.action) {
                        menuItemContent(item: item)
                    }
                } else {
                    Button(action: {}) {
                        menuItemContent(item: item)
                    }
                    .disabled(true)
                }
            }
        } label: {
            label()
        }
    }
    
    private var minimalMenu: some View {
        Menu {
            ForEach(items) { item in
                if item.isEnabled {
                    Button(action: item.action) {
                        Text(item.title)
                    }
                } else {
                    Button(action: {}) {
                        Text(item.title)
                    }
                    .disabled(true)
                }
            }
        } label: {
            label()
        }
    }
    
    private var pillMenu: some View {
        Menu {
            ForEach(items) { item in
                if item.isEnabled {
                    Button(action: item.action) {
                        menuItemContent(item: item)
                    }
                } else {
                    Button(action: {}) {
                        menuItemContent(item: item)
                    }
                    .disabled(true)
                }
            }
        } label: {
            label()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray5))
                .cornerRadius(20)
                .buttonStyle(ScaleButtonStyle(scale: 0.95))
        }
    }
    
    // MARK: - Menu Item Content
    
    @ViewBuilder
    private func menuItemContent(item: MenuItem) -> some View {
        HStack(spacing: 8) {
            if let icon = item.icon {
                Image(systemName: icon)
                    .frame(width: 20)
            }
            
            Text(item.title)
            
            Spacer()
            
            if item.isDestructive {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .foregroundColor(item.isDestructive ? .red : .primary)
    }
}

// MARK: - ScaleButtonStyle

struct MenuScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// 別名としてScaleButtonStyleを提供
typealias ScaleButtonStyle = MenuScaleButtonStyle

// MARK: - Convenience Initializers

extension MenuView {
    /// 学習ログソート用のMenuView
    static func learningLogSortMenu(
        selectedSort: Binding<String>,
        onSelect: @escaping (String) -> Void
    ) -> MenuView {
        let sorts: [String: (icon: String, title: String)] = [
            "dateDesc": ("calendar", "新しい順"),
            "dateAsc": ("calendar", "古い順"),
            "durationDesc": ("clock", "時間が長い順"),
            "durationAsc": ("clock", "時間が短い順"),
            "category": ("tag", "カテゴリ順")
        ]
        
        let items = sorts.map { key, value in
            MenuItem(
                icon: value.icon,
                title: value.title,
                action: { onSelect(key) }
            )
        }
        
        return MenuView(
            title: sorts[selectedSort.wrappedValue]?.title ?? "並べ替え",
            items: items,
            style: .pill
        )
    }
    
    /// カテゴリフィルター用のMenuView
    static func categoryFilterMenu(
        selectedCategory: Binding<String>,
        categories: [String],
        onSelect: @escaping (String) -> Void
    ) -> MenuView {
        var items = [MenuItem(
            icon: "line.horizontal.3.decrease.circle",
            title: "すべて",
            action: { onSelect("all") }
        )]
        
        items.append(contentsOf: categories.map { category in
            MenuItem(
                title: category,
                action: { onSelect(category) }
            )
        })
        
        return MenuView(
            title: selectedCategory.wrappedValue == "all" ? "カテゴリ" : selectedCategory.wrappedValue,
            items: items,
            style: .pill
        )
    }
    
    /// アクションメニュー用のMenuView（編集、削除など）
    static func actionMenu(
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onShare: (() -> Void)? = nil
    ) -> MenuView {
        var items = [
            MenuView.MenuItem(icon: "pencil", title: "編集", action: onEdit),
            MenuView.MenuItem(icon: "square.and.arrow.up", title: "共有", action: onShare ?? {})
        ]
        
        items.append(MenuView.MenuItem(
            icon: "trash",
            title: "削除",
            action: onDelete,
            isDestructive: true
        ))
        
        return MenuView(
            items: items,
            style: .minimal
        ) {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview("Standard Style") {
    MenuView(
        title: "オプション",
        items: [
            MenuView.MenuItem(icon: "pencil", title: "編集", action: {}),
            MenuView.MenuItem(icon: "square.and.arrow.up", title: "共有", action: {}),
            MenuView.MenuItem(icon: "trash", title: "削除", action: {}, isDestructive: true)
        ],
        style: .standard
    )
}

#Preview("Minimal Style") {
    MenuView(
        title: "メニュー",
        items: [
            MenuView.MenuItem(title: "設定", action: {}),
            MenuView.MenuItem(title: "ヘルプ", action: {}),
            MenuView.MenuItem(title: "フィードバック", action: {})
        ],
        style: .minimal
    )
}

#Preview("Pill Style") {
    MenuView(
        title: "並べ替え",
        items: [
            MenuView.MenuItem(icon: "calendar", title: "新しい順", action: {}),
            MenuView.MenuItem(icon: "calendar", title: "古い順", action: {}),
            MenuView.MenuItem(icon: "clock", title: "時間が長い順", action: {}),
            MenuView.MenuItem(icon: "clock", title: "時間が短い順", action: {})
        ],
        style: .pill
    )
}

#Preview("Disabled Items") {
    MenuView(
        title: "アクション",
        items: [
            MenuView.MenuItem(title: "有効な項目", action: {}),
            MenuView.MenuItem(title: "無効な項目", action: {}, isEnabled: false),
            MenuView.MenuItem(title: "破壊的アクション", action: {}, isDestructive: true)
        ],
        style: .standard
    )
}

#Preview("Learning Log Sort Menu") {
    MenuView.learningLogSortMenu(
        selectedSort: .constant("dateDesc"),
        onSelect: { _ in }
    )
}

#Preview("Category Filter Menu") {
    MenuView.categoryFilterMenu(
        selectedCategory: .constant("all"),
        categories: ["数学", "英語", "プログラミング"],
        onSelect: { _ in }
    )
}

#Preview("Action Menu") {
    MenuView.actionMenu(
        onEdit: {},
        onDelete: {},
        onShare: {}
    )
}

#Preview("Dark Mode") {
    MenuView(
        title: "オプション",
        items: [
            MenuView.MenuItem(icon: "pencil", title: "編集", action: {}),
            MenuView.MenuItem(icon: "trash", title: "削除", action: {}, isDestructive: true)
        ],
        style: .standard
    )
    .preferredColorScheme(.dark)
}
