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


