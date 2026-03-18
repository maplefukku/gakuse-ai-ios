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
        StandardChip(
            text: text,
            isSelected: $isSelected,
            icon: icon,
            iconPosition: iconPosition,
            colorScheme: colorScheme,
            onTap: onTap,
            isRemovable: isRemovable,
            onRemove: onRemove
        )
    }
    
    /// 塗りつぶしスタイルチップ
    private var filledChip: some View {
        FilledChip(
            text: text,
            isSelected: $isSelected,
            icon: icon,
            iconPosition: iconPosition,
            colorScheme: colorScheme,
            onTap: onTap,
            isRemovable: isRemovable,
            onRemove: onRemove
        )
    }
    
    /// アウトラインスタイルチップ
    private var outlinedChip: some View {
        OutlinedChip(
            text: text,
            isSelected: $isSelected,
            icon: icon,
            iconPosition: iconPosition,
            colorScheme: colorScheme,
            onTap: onTap,
            isRemovable: isRemovable,
            onRemove: onRemove
        )
    }
    
    /// ミニマルスタイルチップ
    private var minimalChip: some View {
        MinimalChip(
            text: text,
            isSelected: $isSelected,
            icon: icon,
            iconPosition: iconPosition,
            colorScheme: colorScheme,
            onTap: onTap,
            isRemovable: isRemovable,
            onRemove: onRemove
        )
    }
    
    /// ピルスタイルチップ
    private var pillChip: some View {
        PillChip(
            text: text,
            isSelected: $isSelected,
            icon: icon,
            iconPosition: iconPosition,
            colorScheme: colorScheme,
            onTap: onTap,
            isRemovable: isRemovable,
            onRemove: onRemove
        )
    }
    
    /// 丸角スタイルチップ
    private var roundedChip: some View {
        RoundedChip(
            text: text,
            isSelected: $isSelected,
            icon: icon,
            iconPosition: iconPosition,
            colorScheme: colorScheme,
            onTap: onTap,
            isRemovable: isRemovable,
            onRemove: onRemove
        )
    }
}
