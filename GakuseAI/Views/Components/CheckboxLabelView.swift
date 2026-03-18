//
//  CheckboxLabelView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

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
