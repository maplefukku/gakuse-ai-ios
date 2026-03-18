//
//  ListStyle.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

/// リストスタイル
enum ListStyle {
    case standard     // 標準リスト
    case grouped      // グループ化リスト
    case inset        // インセットリスト
    case insetGrouped // インセットグループ化リスト
    case plain        // プレーンリスト
    case card         // カードリスト
}

/// リスト項目
struct ListItem: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String?
    var image: Image?
    var trailingText: String?
    var trailingIcon: String?
    var badge: String?
    var isDivider: Bool = false
    var isDisabled: Bool = false
    var action: (() -> Void)?
}

/// セクションヘッダー
struct ListSection: Identifiable {
    let id = UUID()
    var title: String?
    var items: [ListItem]
    var footer: String?
}
