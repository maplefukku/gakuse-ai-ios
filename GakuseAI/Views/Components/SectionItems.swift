//
//  SectionItems.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-17.
//

import SwiftUI

/// セクションアイテム
struct SectionItems: View {
    let items: [ListItem]
    @Binding var selectedItem: UUID?
    let useCardStyle: Bool

    var body: some View {
        ForEach(items) { item in
            if item.isDivider {
                Divider()
            } else if useCardStyle {
                ListItemCard(item: item, selectedItem: $selectedItem)
            } else {
                ListItemRow(item: item, selectedItem: $selectedItem)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SectionItems(
            items: [
                ListItem(title: "アイテム1", subtitle: "説明1", image: Image(systemName: "star")),
                ListItem(title: "アイテム2", subtitle: "説明2", image: Image(systemName: "heart")),
                ListItem(title: "アイテム3", subtitle: "説明3", image: Image(systemName: "cloud"))
            ],
            selectedItem: .constant(nil),
            useCardStyle: true
        )

        SectionItems(
            items: [
                ListItem(title: "アイテム4", subtitle: "説明4", image: Image(systemName: "bolt")),
                ListItem(title: "アイテム5", subtitle: "説明5", image: Image(systemName: "flame"))
            ],
            selectedItem: .constant(nil),
            useCardStyle: false
        )
    }
    .padding()
}
