//
//  ActionButton.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

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
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 4)
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

    private var shadowColor: Color {
        switch style {
        case .standard, .filled:
            return color.opacity(0.3)
        case .outlined, .minimal:
            return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .standard, .filled:
            return 8
        case .outlined, .minimal:
            return 0
        }
    }
}
