//
//  SectionHeaderStyle.swift
//  GakuseAI
//
//  Created by OpenGoat on 2026-03-16.
//

import SwiftUI

// MARK: - SectionHeaderStyle
/// セクションヘッダーのスタイル定義
public enum SectionHeaderStyle {
    case standard
    case minimal
    case elevated
    case bordered
    case compact
    case card

    var titleFont: Font {
        switch self {
        case .standard, .elevated: return .system(size: 20, weight: .semibold)
        case .minimal: return .system(size: 18, weight: .medium)
        case .bordered: return .system(size: 19, weight: .semibold)
        case .compact: return .system(size: 17, weight: .semibold)
        case .card: return .system(size: 18, weight: .bold)
        }
    }

    var subtitleFont: Font {
        switch self {
        case .standard, .elevated: return .system(size: 14)
        case .minimal: return .system(size: 13)
        case .bordered: return .system(size: 14)
        case .compact: return .system(size: 13)
        case .card: return .system(size: 13)
        }
    }

    var titleColor: Color {
        switch self {
        case .standard, .elevated, .bordered, .card: return .primary
        case .minimal: return .secondary
        case .compact: return .primary
        }
    }

    var subtitleColor: Color {
        switch self {
        case .standard, .elevated, .bordered, .card: return .secondary
        case .minimal: return .secondary.opacity(0.8)
        case .compact: return .secondary
        }
    }

    var iconColor: Color {
        switch self {
        case .standard, .elevated, .bordered: return .accentColor
        case .minimal: return .secondary
        case .compact: return .accentColor
        case .card: return .accentColor
        }
    }

    var actionButtonColor: Color {
        switch self {
        case .standard, .elevated, .bordered, .compact: return .accentColor
        case .minimal: return .secondary
        case .card: return .accentColor
        }
    }

    var backgroundColor: Color {
        switch self {
        case .standard, .minimal, .compact: return .clear
        case .elevated: return Color(UIColor.secondarySystemBackground)
        case .bordered: return Color.clear
        case .card: return Color(UIColor.secondarySystemBackground)
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .standard, .minimal, .compact: return 0
        case .elevated: return 12
        case .bordered: return 8
        case .card: return 12
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .bordered: return 1
        default: return 0
        }
    }

    var borderColor: Color {
        switch self {
        case .bordered: return Color.secondary.opacity(0.3)
        default: return .clear
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .elevated, .card: return 4
        default: return 0
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .elevated, .card: return 0.1
        default: return 0
        }
    }

    var padding: EdgeInsets {
        switch self {
        case .standard: return EdgeInsets(top: 16, leading: 16, bottom: 12, trailing: 16)
        case .minimal: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        case .elevated: return EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        case .bordered: return EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        case .compact: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        case .card: return EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .standard, .elevated, .bordered: return 22
        case .minimal: return 18
        case .compact: return 18
        case .card: return 20
        }
    }
}
