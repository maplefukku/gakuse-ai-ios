//
//  EmptyStateViewExtensions.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

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

// MARK: - EmptyStateScaleButtonStyle

struct EmptyStateScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
