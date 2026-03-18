//
//  CheckboxGroupView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

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
