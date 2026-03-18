//
//  RadioButtonView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// MARK: - Radio Button View

/// ラジオボタンコンポーネント
///
/// - 複数のスタイル: standard, filled, minimal, bordered
/// - カスタマイズ可能な色、サイズ、アニメーション
public struct RadioButtonView: View {
    @Binding private var isSelected: Bool
    private let style: RadioButtonStyle
    private let color: Color
    private let size: CGFloat
    private let lineWidth: CGFloat
    private let isEnabled: Bool

    public enum RadioButtonStyle {
        case standard
        case filled
        case minimal
        case bordered
    }

    /// ラジオボタンビューを初期化
    /// - Parameters:
    ///   - isSelected: 選択状態（バインディング）
    ///   - style: ラジオボタンのスタイル（デフォルト: standard）
    ///   - color: ラジオボタンの色（デフォルト: アクセントカラー）
    ///   - size: ラジオボタンのサイズ（デフォルト: 24）
    ///   - lineWidth: 線の太さ（デフォルト: 2）
    ///   - isEnabled: 有効状態（デフォルト: true）
    public init(
        isSelected: Binding<Bool>,
        style: RadioButtonStyle = .standard,
        color: Color = .accentColor,
        size: CGFloat = 24,
        lineWidth: CGFloat = 2,
        isEnabled: Bool = true
    ) {
        self._isSelected = isSelected
        self.style = style
        self.color = color
        self.size = size
        self.lineWidth = lineWidth
        self.isEnabled = isEnabled
    }

    public var body: some View {
        ZStack {
            circleBackground

            if isSelected {
                selectionIndicator
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(isSelected ? 1.0 : 0.95)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
        .onTapGesture {
            if isEnabled {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isSelected = true
                }
            }
        }
        .opacity(isEnabled ? 1.0 : 0.4)
        .drawingGroup()
    }

    // MARK: - Circle Background

    @ViewBuilder
    private var circleBackground: some View {
        switch style {
        case .standard:
            standardBackground
        case .filled:
            filledBackground
        case .minimal:
            minimalBackground
        case .bordered:
            borderedBackground
        }
    }

    @ViewBuilder
    private var standardBackground: some View {
        Circle()
            .stroke(isSelected ? color : Color(.separator), lineWidth: lineWidth)
            .background(
                Circle()
                    .fill(isSelected ? color.opacity(0.1) : Color.clear)
            )
    }

    @ViewBuilder
    private var filledBackground: some View {
        Circle()
            .fill(isSelected ? color : Color(.systemGray6))
            .overlay(
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }

    @ViewBuilder
    private var minimalBackground: some View {
        Circle()
            .stroke(isSelected ? color : Color(.separator), lineWidth: 1.5)
    }

    @ViewBuilder
    private var borderedBackground: some View {
        Circle()
            .stroke(isSelected ? color : Color(.separator), lineWidth: 2)
            .background(
                Circle()
                    .fill(isSelected ? color.opacity(0.15) : Color(.systemBackground))
            )
    }

    // MARK: - Selection Indicator

    @ViewBuilder
    private var selectionIndicator: some View {
        Circle()
            .fill(color)
            .frame(width: size * 0.5, height: size * 0.5)
            .scaleEffect(isSelected ? 1.0 : 0.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
    }
}
