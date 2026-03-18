//
//  PillChip.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-14.
//

import SwiftUI

/// ピルスタイルチップ
struct PillChip: View {
    let text: String
    @Binding var isSelected: Bool
    let icon: Image?
    let iconPosition: IconPosition
    let colorScheme: ChipColorScheme
    let onTap: (() -> Void)?
    let isRemovable: Bool
    let onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 6) {
            if iconPosition == .leading, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            Text(text)
                .font(.system(size: 14, weight: .medium))

            if iconPosition == .trailing, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            // 削除ボタン
            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, isRemovable ? 16 : 18)
        .padding(.vertical, 9)
        .background(isSelected ? colorScheme.selectedBackgroundColor : colorScheme.backgroundColor)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .clipShape(Capsule())
        .shadow(color: colorScheme.shadowColor, radius: isSelected ? 2 : 0, x: 0, y: 1)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
}
