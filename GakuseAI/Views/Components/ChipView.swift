//
//  ChipView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

/// チップコンポーネント（選択可能なタグ）
///
/// 複数のスタイルを提供するタグ/チップUIコンポーネント
///
/// ## 使用例
/// ```swift
/// ChipView(
///     text: "タグ",
///     isSelected: $isSelected,
///     style: .standard
/// )
/// ```
public struct ChipView: View {

    // MARK: - プロパティ

    /// チップテキスト
    private let text: String

    /// 選択状態
    @Binding private var isSelected: Bool

    /// スタイル
    private let style: ChipStyle

    /// アイコン（オプション）
    private let icon: Image?

    /// アイコン位置
    private let iconPosition: IconPosition

    /// カラースキーム
    private let colorScheme: ChipColorScheme

    /// 選択時のコールバック
    private let onTap: (() -> Void)?

    /// 削除可能かどうか
    private let isRemovable: Bool

    /// 削除時のコールバック
    private let onRemove: (() -> Void)?

    // MARK: - 初期化

    /// 標準初期化
    /// - Parameters:
    ///   - text: チップテキスト
    ///   - isSelected: 選択状態
    ///   - style: スタイル
    ///   - icon: アイコン（オプション）
    ///   - iconPosition: アイコン位置（デフォルト: .leading）
    ///   - colorScheme: カラースキーム（デフォルト: .primary）
    ///   - onTap: 選択時のコールバック
    ///   - isRemovable: 削除可能かどうか（デフォルト: false）
    ///   - onRemove: 削除時のコールバック
    public init(
        text: String,
        isSelected: Binding<Bool>,
        style: ChipStyle = ChipStyle.standard,
        icon: Image? = nil,
        iconPosition: IconPosition = .leading,
        colorScheme: ChipColorScheme = ChipColorScheme.primary,
        onTap: (() -> Void)? = nil,
        isRemovable: Bool = false,
        onRemove: (() -> Void)? = nil
    ) {
        self.text = text
        self._isSelected = isSelected
        self.style = style
        self.icon = icon
        self.iconPosition = iconPosition
        self.colorScheme = colorScheme
        self.onTap = onTap
        self.isRemovable = isRemovable
        self.onRemove = onRemove
    }
    
    // MARK: - ボディ
    
    public var body: some View {
        Group {
            switch style {
            case .standard:
                standardChip
            case .filled:
                filledChip
            case .outlined:
                outlinedChip
            case .minimal:
                minimalChip
            case .pill:
                pillChip
            case .rounded:
                roundedChip
            }
        }
        .drawingGroup()
    }
    
    // MARK: - サブビュー
    
    /// 標準スタイルチップ
    private var standardChip: some View {
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
        .padding(.horizontal, isRemovable ? 12 : 14)
        .padding(.vertical, 8)
        .background(isSelected ? colorScheme.selectedBackgroundColor : colorScheme.backgroundColor)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(colorScheme.borderColor, lineWidth: isSelected ? 0 : 1)
        )
        .shadow(color: colorScheme.shadowColor, radius: isSelected ? 2 : 0, x: 0, y: 1)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
    
    /// 塗りつぶしスタイルチップ
    private var filledChip: some View {
        HStack(spacing: 6) {
            if iconPosition == .leading, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            Text(text)
                .font(.system(size: 14, weight: .semibold))

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
        .padding(.horizontal, isRemovable ? 14 : 16)
        .padding(.vertical, 10)
        .background(isSelected ? colorScheme.selectedBackgroundColor : colorScheme.backgroundColor)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .cornerRadius(20)
        .shadow(color: colorScheme.shadowColor, radius: isSelected ? 3 : 1, x: 0, y: 2)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
    
    /// アウトラインスタイルチップ
    private var outlinedChip: some View {
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
        .padding(.horizontal, isRemovable ? 12 : 14)
        .padding(.vertical, 8)
        .background(Color.clear)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? colorScheme.selectedBackgroundColor : colorScheme.borderColor, lineWidth: 2)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
    
    /// ミニマルスタイルチップ
    private var minimalChip: some View {
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
    
    /// ピルスタイルチップ
    private var pillChip: some View {
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
    
    /// 丸角スタイルチップ
    private var roundedChip: some View {
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
        .padding(.horizontal, isRemovable ? 12 : 14)
        .padding(.vertical, 8)
        .background(isSelected ? colorScheme.selectedBackgroundColor : colorScheme.backgroundColor)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme.borderColor, lineWidth: isSelected ? 0 : 1)
        )
        .shadow(color: colorScheme.shadowColor, radius: isSelected ? 2 : 0, x: 0, y: 1)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
}
