//
//  CheckboxView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// MARK: - Checkbox View

/// チェックボックスコンポーネント
///
/// - 複数のスタイル: standard, filled, minimal, bordered
/// - カスタマイズ可能な色、サイズ、アニメーション
/// - 不確定状態に対応
public struct CheckboxView: View {
    @Binding private var isChecked: Bool
    private let style: CheckboxStyle
    private let color: Color
    private let size: CGFloat
    private let cornerRadius: CGFloat
    private let lineWidth: CGFloat
    private let isIndeterminate: Bool
    private let isEnabled: Bool
    
    public enum CheckboxStyle {
        case standard
        case filled
        case minimal
        case bordered
    }
    
    /// チェックボックスビューを初期化
    /// - Parameters:
    ///   - isChecked: チェック状態（バインディング）
    ///   - style: チェックボックスのスタイル（デフォルト: standard）
    ///   - color: チェックボックスの色（デフォルト: アクセントカラー）
    ///   - size: チェックボックスのサイズ（デフォルト: 24）
    ///   - cornerRadius: 角丸（デフォルト: 6）
    ///   - lineWidth: 線の太さ（デフォルト: 2）
    ///   - isIndeterminate: 不確定状態（デフォルト: false）
    ///   - isEnabled: 有効状態（デフォルト: true）
    public init(
        isChecked: Binding<Bool>,
        style: CheckboxStyle = .standard,
        color: Color = .accentColor,
        size: CGFloat = 24,
        cornerRadius: CGFloat = 6,
        lineWidth: CGFloat = 2,
        isIndeterminate: Bool = false,
        isEnabled: Bool = true
    ) {
        self._isChecked = isChecked
        self.style = style
        self.color = color
        self.size = size
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
        self.isIndeterminate = isIndeterminate
        self.isEnabled = isEnabled
    }
    
    public var body: some View {
        ZStack {
            checkboxBackground
            
            if isChecked || isIndeterminate {
                checkmarkOrIndeterminate
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(isChecked || isIndeterminate ? 1.0 : 0.95)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isChecked)
        .onTapGesture {
            if isEnabled {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isChecked.toggle()
                }
            }
        }
        .opacity(isEnabled ? 1.0 : 0.4)
        .drawingGroup()
    }
    
    // MARK: - Checkbox Background
    
    @ViewBuilder
    private var checkboxBackground: some View {
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
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(isChecked || isIndeterminate ? color : Color(.separator), lineWidth: lineWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill((isChecked || isIndeterminate) ? color.opacity(0.1) : Color.clear)
            )
    }
    
    @ViewBuilder
    private var filledBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill((isChecked || isIndeterminate) ? color : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
    
    @ViewBuilder
    private var minimalBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke((isChecked || isIndeterminate) ? color : Color(.separator), lineWidth: 1.5)
    }
    
    @ViewBuilder
    private var borderedBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke((isChecked || isIndeterminate) ? color : Color(.separator), lineWidth: 2)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill((isChecked || isIndeterminate) ? color.opacity(0.15) : Color(.systemBackground))
            )
    }
    
    // MARK: - Checkmark or Indeterminate
    
    @ViewBuilder
    private var checkmarkOrIndeterminate: some View {
        if isIndeterminate {
            indeterminateMark
        } else {
            checkmark
        }
    }
    
    @ViewBuilder
    private var checkmark: some View {
        Image(systemName: "checkmark")
            .font(.system(size: size * 0.6, weight: .bold))
            .foregroundColor(color)
            .scaleEffect(isChecked ? 1.0 : 0.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isChecked)
    }
    
    @ViewBuilder
    private var indeterminateMark: some View {
        Rectangle()
            .fill(color)
            .frame(width: size * 0.5, height: size * 0.15)
            .cornerRadius(size * 0.03)
            .scaleEffect(isIndeterminate ? 1.0 : 0.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isIndeterminate)
    }
}

// MARK: - Checkbox Label

/// ラベル付きチェックボックス
public struct CheckboxLabelView: View {
    @Binding private var isChecked: Bool
    private let label: String
    private let style: CheckboxView.CheckboxStyle
    private let color: Color
    private let size: CGFloat
    private let isEnabled: Bool
    
    public init(
        isChecked: Binding<Bool>,
        label: String,
        style: CheckboxView.CheckboxStyle = .standard,
        color: Color = .accentColor,
        size: CGFloat = 24,
        isEnabled: Bool = true
    ) {
        self._isChecked = isChecked
        self.label = label
        self.style = style
        self.color = color
        self.size = size
        self.isEnabled = isEnabled
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            CheckboxView(
                isChecked: $isChecked,
                style: style,
                color: color,
                size: size,
                isEnabled: isEnabled
            )
            
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(isEnabled ? .primary : .secondary)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isEnabled {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isChecked.toggle()
                }
            }
        }
    }
}

// MARK: - Checkbox Group

/// チェックボックスグループ
public struct CheckboxGroupView: View {
    @Binding private var selectedIndices: Set<Int>
    private let items: [String]
    private let style: CheckboxView.CheckboxStyle
    private let color: Color
    private let size: CGFloat
    private let spacing: CGFloat
    
    public init(
        selectedIndices: Binding<Set<Int>>,
        items: [String],
        style: CheckboxView.CheckboxStyle = .standard,
        color: Color = .accentColor,
        size: CGFloat = 24,
        spacing: CGFloat = 12
    ) {
        self._selectedIndices = selectedIndices
        self.items = items
        self.style = style
        self.color = color
        self.size = size
        self.spacing = spacing
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                CheckboxLabelView(
                    isChecked: Binding(
                        get: { selectedIndices.contains(index) },
                        set: { newValue in
                            if newValue {
                                selectedIndices.insert(index)
                            } else {
                                selectedIndices.remove(index)
                            }
                        }
                    ),
                    label: item,
                    style: style,
                    color: color,
                    size: size
                )
            }
        }
    }
}


