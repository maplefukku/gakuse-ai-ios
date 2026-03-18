//
//  ListItemCard.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-17.
//

import SwiftUI

/// リストアイテムカード
struct ListItemCard: View {
    let item: ListItem
    @Binding var selectedItem: UUID?

    var body: some View {
        Button(action: {
            if !item.isDisabled {
                selectedItem = item.id
                item.action?()
            }
        }) {
            HStack(spacing: 12) {
                // アイコン
                if let image = item.image {
                    image
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 4) {
                    // タイトル
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(item.isDisabled ? .secondary : .primary)

                    // サブタイトル
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // バッジ
                if let badge = item.badge {
                    Text(badge)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(14)
                }
            }
            .padding(16)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(item.isDisabled)
        .opacity(item.isDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    VStack(spacing: 16) {
        ListItemCard(
            item: ListItem(
                title: "SwiftUI学習",
                subtitle: "iOSアプリ開発フレームワーク",
                image: Image(systemName: "swift"),
                badge: "3"
            ),
            selectedItem: .constant(nil)
        )

        ListItemCard(
            item: ListItem(
                title: "英語学習",
                subtitle: "TOEIC対策",
                image: Image(systemName: "book.closed")
            ),
            selectedItem: .constant(nil)
        )
    }
    .padding()
}
