//
//  ChipColorScheme.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// チップカラースキーム
///
/// チップコンポーネントの色設定を管理する列挙型
public enum ChipColorScheme {
    case primary       // プライマリ
    case secondary     // セカンダリ
    case success       // 成功
    case warning       // 警告
    case error         // エラー
    case custom(Color) // カスタム

    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color(.systemGray6)
        case .secondary:
            return Color.purple.opacity(0.1)
        case .success:
            return Color.green.opacity(0.1)
        case .warning:
            return Color.orange.opacity(0.1)
        case .error:
            return Color.red.opacity(0.1)
        case .custom(let color):
            return color.opacity(0.1)
        }
    }

    var selectedBackgroundColor: Color {
        switch self {
        case .primary:
            return .blue
        case .secondary:
            return .purple
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        case .custom(let color):
            return color
        }
    }

    var textColor: Color {
        switch self {
        case .primary:
            return .primary
        case .secondary:
            return .purple
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        case .custom(let color):
            return color
        }
    }

    var selectedTextColor: Color {
        switch self {
        case .primary, .secondary, .success, .warning, .error:
            return .white
        case .custom(_):
            return .white
        }
    }

    var borderColor: Color {
        switch self {
        case .primary:
            return Color(.systemGray4)
        case .secondary:
            return Color.purple.opacity(0.3)
        case .success:
            return Color.green.opacity(0.3)
        case .warning:
            return Color.orange.opacity(0.3)
        case .error:
            return Color.red.opacity(0.3)
        case .custom(let color):
            return color.opacity(0.3)
        }
    }

    var shadowColor: Color {
        switch self {
        case .primary, .secondary:
            return Color.black.opacity(0.1)
        case .success:
            return Color.green.opacity(0.2)
        case .warning:
            return Color.orange.opacity(0.2)
        case .error:
            return Color.red.opacity(0.2)
        case .custom(let color):
            return color.opacity(0.2)
        }
    }
}
