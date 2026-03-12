//
//  ChipGroup.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// チップグループ（複数のチップを管理）
public struct ChipGroup: View {

    // MARK: - プロパティ

    /// チップデータ
    private let chips: [ChipData]

    /// 選択されたチップ
    @Binding private var selectedChips: Set<String>

    /// 複数選択可能か
    private let allowsMultipleSelection: Bool

    /// スタイル
    private let style: ChipStyle

    /// カラースキーム
    private let colorScheme: ChipColorScheme

    /// 選択時のコールバック
    private let onChange: ((Set<String>) -> Void)?

    // MARK: - ChipData

    /// チップデータ
    public struct ChipData: Identifiable {
        public let id: String
        public let text: String
        public let icon: Image?

        public init(
            id: String,
            text: String,
            icon: Image? = nil
        ) {
            self.id = id
            self.text = text
            self.icon = icon
        }
    }

    // MARK: - 初期化

    public init(
        chips: [ChipData],
        selectedChips: Binding<Set<String>>,
        allowsMultipleSelection: Bool = true,
        style: ChipStyle = .standard,
        colorScheme: ChipColorScheme = .primary,
        onChange: ((Set<String>) -> Void)? = nil
    ) {
        self.chips = chips
        self._selectedChips = selectedChips
        self.allowsMultipleSelection = allowsMultipleSelection
        self.style = style
        self.colorScheme = colorScheme
        self.onChange = onChange
    }

    // MARK: - ボディ

    public var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 80))
            ],
            spacing: 8
        ) {
            ForEach(chips) { chip in
                ChipView(
                    text: chip.text,
                    isSelected: Binding(
                        get: { selectedChips.contains(chip.id) },
                        set: { newValue in
                            if newValue {
                                if allowsMultipleSelection {
                                    selectedChips.insert(chip.id)
                                } else {
                                    selectedChips = [chip.id]
                                }
                            } else {
                                selectedChips.remove(chip.id)
                            }
                            onChange?(selectedChips)
                        }
                    ),
                    style: style,
                    icon: chip.icon,
                    colorScheme: colorScheme
                )
            }
        }
        .drawingGroup()
    }
}

// MARK: - Preview

#Preview("ChipGroup") {
    ChipGroup(
        chips: [
            ChipGroup.ChipData(id: "1", text: "SwiftUI", icon: Image(systemName: "swift")),
            ChipGroup.ChipData(id: "2", text: "iOS", icon: Image(systemName: "iphone")),
            ChipGroup.ChipData(id: "3", text: "Android", icon: Image(systemName: "android")),
            ChipGroup.ChipData(id: "4", text: "Web", icon: Image(systemName: "globe")),
            ChipGroup.ChipData(id: "5", text: "UI/UX", icon: Image(systemName: "paintbrush")),
            ChipGroup.ChipData(id: "6", text: "Backend", icon: Image(systemName: "server")),
        ],
        selectedChips: .constant(["1", "3"]),
        allowsMultipleSelection: true
    )
}
