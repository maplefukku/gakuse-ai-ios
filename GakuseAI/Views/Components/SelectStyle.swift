//
//  SelectStyle.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// 選択スタイル
enum SelectStyle {
    case standard     // 標準選択（ピッカー）
    case dropdown     // ドロップダウン選択
    case segmented    // セグメント選択
    case radio        // ラジオボタン選択
    case checkbox     // チェックボックス選択（複数選択）
    case card         // カード選択
}

/// 選択肢
struct SelectOption: Identifiable, Hashable, Equatable {
    let id = UUID()
    var label: String
    var value: String
    var icon: String?
    var subtitle: String?
    var isEnabled: Bool = true
    var isSelected: Bool = false

    static func == (lhs: SelectOption, rhs: SelectOption) -> Bool {
        lhs.id == rhs.id
    }
}
