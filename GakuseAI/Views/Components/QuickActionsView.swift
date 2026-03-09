//
//  QuickActionsView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// MARK: - Quick Actions View

/// クイックアクションを表示するビュー
///
/// - 複数のスタイル: grid, horizontal, list
/// - カスタマイズ可能なアクション、色、サイズ
public struct QuickActionsView: View {
    private let actions: [QuickAction]
    private let style: ActionStyle
    private let columns: Int
    private let spacing: CGFloat
    
    public enum ActionStyle {
        case grid
        case horizontal
        case list
    }
    
    public struct QuickAction: Identifiable {
        public let id = UUID()
        public let title: String
        public let icon: String
        public let color: Color
        public let action: () -> Void
        
        public init(
            title: String,
            icon: String,
            color: Color = .blue,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.icon = icon
            self.color = color
            self.action = action
        }
    }
    
    /// クイックアクションビューを初期化
    /// - Parameters:
    ///   - actions: アクションの配列
    ///   - style: アクションのスタイル（デフォルト: grid）
    ///   - columns: グリッドの列数（デフォルト: 4）
    ///   - spacing: アクション間の間隔（デフォルト: 16）
    public init(
        actions: [QuickAction],
        style: ActionStyle = .grid,
        columns: Int = 4,
        spacing: CGFloat = 16
    ) {
        self.actions = actions
        self.style = style
        self.columns = columns
        self.spacing = spacing
    }
    
    public var body: some View {
        content
            .drawingGroup()
    }
    
    @ViewBuilder
    private var content: some View {
        switch style {
        case .grid:
            gridLayout
        case .horizontal:
            horizontalLayout
        case .list:
            listLayout
        }
    }
    
    // MARK: - Grid Layout
    
    @ViewBuilder
    private var gridLayout: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            ForEach(actions) { action in
                quickActionButton(for: action)
            }
        }
    }
    
    // MARK: - Horizontal Layout
    
    @ViewBuilder
    private var horizontalLayout: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(actions) { action in
                    quickActionButton(for: action)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - List Layout
    
    @ViewBuilder
    private var listLayout: some View {
        VStack(spacing: 12) {
            ForEach(actions) { action in
                listActionButton(for: action)
            }
        }
    }
    
    // MARK: - Quick Action Button
    
    @ViewBuilder
    private func quickActionButton(for action: QuickAction) -> some View {
        Button(action: action.action) {
            VStack(spacing: 8) {
                // Icon
                Image(systemName: action.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(action.color)
                            .shadow(color: action.color.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                // Title
                Text(action.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(QuickActionButtonStyle())
    }
    
    // MARK: - List Action Button
    
    @ViewBuilder
    private func listActionButton(for action: QuickAction) -> some View {
        Button(action: action.action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: action.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(action.color)
                    )
                
                // Title
                Text(action.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(QuickActionButtonStyle())
    }
}

// MARK: - Quick Action Button Style

private struct QuickActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Action Button View

/// 個別のアクションボタン
public struct ActionButtonView: View {
    private let title: String
    private let icon: String
    private let color: Color
    private let style: ButtonStyle
    private let size: ButtonSize
    private let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    public enum ButtonStyle {
        case standard
        case filled
        case outlined
        case minimal
    }
    
    public enum ButtonSize {
        case small
        case medium
        case large
    }
    
    /// アクションボタンを初期化
    /// - Parameters:
    ///   - title: ボタンタイトル
    ///   - icon: アイコン名
    ///   - color: ボタンの色
    ///   - style: ボタンのスタイル（デフォルト: standard）
    ///   - size: ボタンのサイズ（デフォルト: medium）
    ///   - action: アクション
    public init(
        title: String,
        icon: String,
        color: Color = .blue,
        style: ButtonStyle = .standard,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.style = style
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            action()
            let feedback = UIImpactFeedbackGenerator(style: .medium)
            feedback.impactOccurred()
        }) {
            buttonContent
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .drawingGroup()
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        HStack(spacing: horizontalSpacing) {
            // Icon
            Image(systemName: icon)
                .font(iconFont)
                .foregroundColor(iconColor)
            
            // Title
            Text(title)
                .font(titleFont)
                .foregroundColor(titleColor)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(backgroundColor)
        .overlay(border)
        .cornerRadius(cornerRadius)
        .shadow(shadow)
    }
    
    // MARK: - Properties
    
    private var horizontalSpacing: CGFloat {
        switch size {
        case .small:
            return 6
        case .medium:
            return 8
        case .large:
            return 10
        }
    }
    
    private var iconFont: Font {
        switch size {
        case .small:
            .system(size: 16, weight: .medium)
        case .medium:
            .system(size: 18, weight: .medium)
        case .large:
            .system(size: 20, weight: .medium)
        }
    }
    
    private var titleFont: Font {
        switch size {
        case .small:
            .system(size: 14, weight: .medium)
        case .medium:
            .system(size: 16, weight: .semibold)
        case .large:
            .system(size: 18, weight: .semibold)
        }
    }
    
    private var iconColor: Color {
        switch style {
        case .standard:
            return .white
        case .filled:
            return .white
        case .outlined:
            return color
        case .minimal:
            return color
        }
    }
    
    private var titleColor: Color {
        switch style {
        case .standard:
            return .white
        case .filled:
            return .white
        case .outlined:
            return color
        case .minimal:
            return .primary
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small:
            return 12
        case .medium:
            return 16
        case .large:
            return 20
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small:
            return 8
        case .medium:
            return 10
        case .large:
            return 12
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .standard:
            return color
        case .filled:
            return color
        case .outlined:
            return Color.clear
        case .minimal:
            return Color(.systemBackground)
        }
    }
    
    @ViewBuilder
    private var border: some View {
        if style == .outlined {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: 2)
        }
    }
    
    private var cornerRadius: CGFloat {
        switch size {
        case .small:
            return 8
        case .medium:
            return 10
        case .large:
            return 12
        }
    }
    
    private var shadow: Shadow {
        switch style {
        case .standard:
            return .drop(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        case .filled:
            return .drop(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        case .outlined:
            return .clear
        case .minimal:
            return .clear
        }
    }
}

// MARK: - Previews

#Preview("Grid Style") {
    VStack(alignment: .leading, spacing: 20) {
        Text("Grid Style")
            .font(.headline)
        
        QuickActionsView(
            actions: [
                QuickAction(title: "新規作成", icon: "plus.circle.fill", color: .blue) {
                    print("New action")
                },
                QuickAction(title: "検索", icon: "magnifyingglass", color: .green) {
                    print("Search action")
                },
                QuickAction(title: "設定", icon: "gearshape.fill", color: .gray) {
                    print("Settings action")
                },
                QuickAction(title: "共有", icon: "square.and.arrow.up", color: .orange) {
                    print("Share action")
                }
            ],
            style: .grid,
            columns: 4
        )
    }
    .padding()
}

#Preview("Horizontal Style") {
    VStack(alignment: .leading, spacing: 20) {
        Text("Horizontal Style")
            .font(.headline)
        
        QuickActionsView(
            actions: [
                QuickAction(title: "新規作成", icon: "plus.circle.fill", color: .blue) {
                    print("New action")
                },
                QuickAction(title: "検索", icon: "magnifyingglass", color: .green) {
                    print("Search action")
                },
                QuickAction(title: "設定", icon: "gearshape.fill", color: .gray) {
                    print("Settings action")
                },
                QuickAction(title: "共有", icon: "square.and.arrow.up", color: .orange) {
                    print("Share action")
                },
                QuickAction(title: "削除", icon: "trash.fill", color: .red) {
                    print("Delete action")
                }
            ],
            style: .horizontal
        )
    }
    .padding()
}

#Preview("List Style") {
    VStack(alignment: .leading, spacing: 20) {
        Text("List Style")
            .font(.headline)
        
        QuickActionsView(
            actions: [
                QuickAction(title: "新規作成", icon: "plus.circle.fill", color: .blue) {
                    print("New action")
                },
                QuickAction(title: "検索", icon: "magnifyingglass", color: .green) {
                    print("Search action")
                },
                QuickAction(title: "設定", icon: "gearshape.fill", color: .gray) {
                    print("Settings action")
                },
                QuickAction(title: "共有", icon: "square.and.arrow.up", color: .orange) {
                    print("Share action")
                }
            ],
            style: .list
        )
    }
    .padding()
}

#Preview("Action Button") {
    VStack(spacing: 20) {
        Text("Action Buttons")
            .font(.headline)
        
        VStack(spacing: 12) {
            ActionButtonView(
                title: "Standard",
                icon: "star.fill",
                color: .blue,
                style: .standard,
                size: .medium
            ) {
                print("Standard button tapped")
            }
            
            ActionButtonView(
                title: "Filled",
                icon: "heart.fill",
                color: .red,
                style: .filled,
                size: .medium
            ) {
                print("Filled button tapped")
            }
            
            ActionButtonView(
                title: "Outlined",
                icon: "checkmark.circle.fill",
                color: .green,
                style: .outlined,
                size: .medium
            ) {
                print("Outlined button tapped")
            }
            
            ActionButtonView(
                title: "Minimal",
                icon: "circle.fill",
                color: .purple,
                style: .minimal,
                size: .medium
            ) {
                print("Minimal button tapped")
            }
        }
        .padding()
    }
}
