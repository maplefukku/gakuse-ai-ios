//
//  EmptyStateView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//  Copyright © 2026 GakuseAI. All rights reserved.
//

import SwiftUI

/// 空の状態を表示する汎用コンポーネント
///
/// - 複数のスタイル: standard, minimal, illustrated
/// - カスタマイズ可能なアイコン、タイトル、メッセージ、アクションボタン
struct EmptyStateView: View {
    // MARK: - Styles
    
    enum Style {
        case standard
        case minimal
        case illustrated
    }
    
    // MARK: - Properties
    
    private let icon: String?
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let style: Style
    
    // MARK: - Initialization
    
    /// 基本的なEmptyStateViewを初期化
    init(
        icon: String? = nil,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        style: Style = .standard
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.style = style
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
            .drawingGroup()
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        switch style {
        case .standard:
            standardView
        case .minimal:
            minimalView
        case .illustrated:
            illustratedView
        }
    }
    
    // MARK: - Style Views
    
    private var standardView: some View {
        VStack(spacing: 20) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            if let message = message {
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
                .buttonStyle(ScaleButtonStyle(scale: 0.95))
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 40)
    }
    
    private var minimalView: some View {
        VStack(spacing: 16) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let message = message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 32)
    }
    
    private var illustratedView: some View {
        VStack(spacing: 24) {
            if let icon = icon {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: icon)
                        .font(.system(size: 56))
                        .foregroundColor(.accentColor)
                }
                .padding(.top, 60)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                if let message = message {
                    Text(message)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack {
                        Text(actionTitle)
                            .font(.body)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.body)
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(ScaleButtonStyle(scale: 0.95))
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 60)
    }
}

// MARK: - Convenience Initializers

extension EmptyStateView {
    /// 学習ログ用のEmptyStateView
    static func noLearningLogs(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "book.closed",
            title: "学習ログがありません",
            message: "最初の学習ログを記録してみましょう。",
            actionTitle: "学習ログを追加",
            action: action,
            style: .illustrated
        )
    }
    
    /// ポートフォリオ用のEmptyStateView
    static func noPortfolio(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "doc.text",
            title: "ポートフォリオが空です",
            message: "学習ログをポートフォリオに公開して、あなたの学習成果をシェアしましょう。",
            actionTitle: "公開する",
            action: action,
            style: .illustrated
        )
    }
    
    /// 検索結果用のEmptyStateView
    static func noSearchResults() -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "検索結果がありません",
            message: "別のキーワードで試してみてください。",
            style: .standard
        )
    }
    
    /// ネットワークエラー用のEmptyStateView
    static func networkError(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.exclamationmark",
            title: "通信エラー",
            message: "インターネット接続を確認して、もう一度お試しください。",
            actionTitle: "再試行",
            action: action,
            style: .standard
        )
    }
}

// MARK: - ScaleButtonStyle

struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Standard Style") {
    EmptyStateView(
        icon: "tray",
        title: "データがありません",
        message: "データを追加するとここに表示されます。",
        actionTitle: "追加する",
        action: {}
    )
}

#Preview("Minimal Style") {
    EmptyStateView(
        icon: "clock",
        title: "履歴がありません",
        style: .minimal
    )
}

#Preview("Illustrated Style") {
    EmptyStateView(
        icon: "star.fill",
        title: "お気に入りがありません",
        message: "お気に入りに追加すると、ここに表示されます。",
        actionTitle: "見てみる",
        action: {},
        style: .illustrated
    )
}

#Preview("No Learning Logs") {
    EmptyStateView.noLearningLogs(action: {})
}

#Preview("No Portfolio") {
    EmptyStateView.noPortfolio(action: {})
}

#Preview("No Search Results") {
    EmptyStateView.noSearchResults()
}

#Preview("Network Error") {
    EmptyStateView.networkError(action: {})
}

#Preview("Dark Mode") {
    EmptyStateView(
        icon: "tray",
        title: "データがありません",
        message: "データを追加するとここに表示されます。",
        actionTitle: "追加する",
        action: {}
    )
    .preferredColorScheme(.dark)
}
