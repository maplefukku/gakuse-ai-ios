//
//  MinimalChip.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-14.
//

import SwiftUI

/// ミニマルスタイルチップ
struct MinimalChip: View {
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
                    .font(.system(size: 12))
            }

            Text(text)
                .font(.system(size: 13))

            if iconPosition == .trailing, let icon = icon {
                icon
                    .font(.system(size: 12))
            }

            // 削除ボタン
            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 14, height: 14)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, isRemovable ? 8 : 10)
        .padding(.vertical, 5)
        .background(isSelected ? colorScheme.selectedBackgroundColor.opacity(0.1) : Color.clear)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .cornerRadius(4)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
}
