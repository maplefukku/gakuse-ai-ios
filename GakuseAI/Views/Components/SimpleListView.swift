//
//  SimpleListView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

/// シンプルリストビュー
struct SimpleListView: View {
    let items: [ListItem]

    var body: some View {
        ListView(
            sections: [ListSection(items: items)],
            style: .plain
        )
    }
}

/// カードリストビュー
struct CardListView: View {
    let items: [ListItem]

    var body: some View {
        ListView(
            sections: [ListSection(items: items)],
            style: .card
        )
    }
}

/// グループ化リストビュー
struct GroupedListView: View {
    let sections: [ListSection]

    var body: some View {
        ListView(
            sections: sections,
            style: .insetGrouped
        )
    }
}
