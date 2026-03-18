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
    private let style: SectionHeaderStyle

    public init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        style: SectionHeaderStyle = .standard
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
    private let style: SectionHeaderStyle

    public init(
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void,
        actionTitle: String,
        style: SectionHeaderStyle = .standard
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
