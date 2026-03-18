//
//  ListItemRow.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-17.
//

import SwiftUI

/// リストアイテム行
struct ListItemRow: View {
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
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 2) {
                    // タイトル
                    Text(item.title)
                        .font(.body)
                        .foregroundColor(item.isDisabled ? .secondary : .primary)

                    // サブタイトル
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // トレーリング要素
                HStack(spacing: 8) {
                    // バッジ
                    if let badge = item.badge {
                        Text(badge)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }

                    // トレーリングテキスト
                    if let trailingText = item.trailingText {
                        Text(trailingText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // トレーリングアイコン
                    if let trailingIcon = item.trailingIcon {
                        Image(systemName: trailingIcon)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if !item.isDisabled {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(item.isDisabled)
        .opacity(item.isDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    VStack(spacing: 8) {
        ListItemRow(
            item: ListItem(
                title: "設定",
                subtitle: "アプリ設定を管理",
                image: Image(systemName: "gear"),
                trailingText: "ON",
                badge: "2"
            ),
            selectedItem: .constant(nil)
        )

        ListItemRow(
            item: ListItem(
                title: "プロフィール",
                subtitle: "プロフィールを編集",
                image: Image(systemName: "person"),
                isDisabled: true
            ),
            selectedItem: .constant(nil)
        )
    }
    .padding()
}
