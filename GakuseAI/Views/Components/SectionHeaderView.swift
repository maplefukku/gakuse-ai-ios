//
//  SectionHeaderView.swift
//  GakuseAI
//
//  Created by OpenGoat on 2026-03-10.
//

import SwiftUI

// MARK: - SectionHeaderView
/// セクションヘッダーを表示するコンポーネント
public struct SectionHeaderView: View {
    // MARK: - Properties
    private let title: String
    private let subtitle: String?
    private let style: SectionHeaderStyle
    private let leadingIcon: String?
    private let trailingAction: (() -> Void)?
    private let trailingActionTitle: String?

    // MARK: - Style Definition
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

    // MARK: - Initializer
    public init(
        title: String,
        subtitle: String? = nil,
        style: SectionHeaderStyle = .standard,
        leadingIcon: String? = nil,
        trailingAction: (() -> Void)? = nil,
        trailingActionTitle: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.leadingIcon = leadingIcon
        self.trailingAction = trailingAction
        self.trailingActionTitle = trailingActionTitle
    }

    // MARK: - Body
    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 左側アイコン
            if let leadingIcon = leadingIcon {
                Image(systemName: leadingIcon)
                    .font(.system(size: style.iconSize, weight: .medium))
                    .foregroundColor(style.iconColor)
                    .frame(width: style.iconSize + 4)
            }

            // タイトルとサブタイトル
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(style.titleFont)
                    .foregroundColor(style.titleColor)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(style.subtitleFont)
                        .foregroundColor(style.subtitleColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()

            // 右側アクションボタン
            if let trailingAction = trailingAction, let trailingActionTitle = trailingActionTitle {
                Button(action: trailingAction) {
                    Text(trailingActionTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(style.actionButtonColor)
                }
            }
        }
        .padding(style.padding)
        .background(style.backgroundColor)
        .cornerRadius(style.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(style.borderColor, lineWidth: style.borderWidth)
        )
        .shadow(
            color: Color.black.opacity(style.shadowOpacity),
            radius: style.shadowRadius,
            x: 0,
            y: style.shadowRadius / 2
        )
        .drawingGroup()
    }
}

// MARK: - SimpleSectionHeaderView
/// シンプルなセクションヘッダー
public struct SimpleSectionHeaderView: View {
    private let title: String
    private let subtitle: String?

    public init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        SectionHeaderView(
            title: title,
            subtitle: subtitle,
            style: .minimal
        )
    }
}

// MARK: - IconSectionHeaderView
/// アイコン付きセクションヘッダー
public struct IconSectionHeaderView: View {
    private let title: String
    private let subtitle: String?
    private let icon: String
    private let style: SectionHeaderView.SectionHeaderStyle

    public init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        style: SectionHeaderView.SectionHeaderStyle = .standard
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.style = style
    }

    public var body: some View {
        SectionHeaderView(
            title: title,
            subtitle: subtitle,
            style: style,
            leadingIcon: icon
        )
    }
}

// MARK: - ActionSectionHeaderView
/// アクションボタン付きセクションヘッダー
public struct ActionSectionHeaderView: View {
    private let title: String
    private let subtitle: String?
    private let action: () -> Void
    private let actionTitle: String
    private let style: SectionHeaderView.SectionHeaderStyle

    public init(
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void,
        actionTitle: String,
        style: SectionHeaderView.SectionHeaderStyle = .standard
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.actionTitle = actionTitle
        self.style = style
    }

    public var body: some View {
        SectionHeaderView(
            title: title,
            subtitle: subtitle,
            style: style,
            trailingAction: action,
            trailingActionTitle: actionTitle
        )
    }
}


