//
//  ListView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
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

/// メインリストビュー
struct ListView: View {
    let sections: [ListSection]
    let style: ListStyle
    @State private var selectedItem: UUID?

    var body: some View {
        switch style {
        case .standard:
            standardList
        case .grouped:
            groupedList
        case .inset:
            insetList
        case .insetGrouped:
            insetGroupedList
        case .plain:
            plainList
        case .card:
            cardList
        }
    }

    private var standardList: some View {
        List {
            ForEach(sections) { section in
                if let title = section.title {
                    Section(header: Text(title)) {
                        sectionItems(section.items)
                    }
                } else {
                    sectionItems(section.items)
                }

                if let footer = section.footer {
                    Section(footer: Text(footer)) {}
                }
            }
        }
        .listStyle(.inset)
    }

    private var groupedList: some View {
        List {
            ForEach(sections) { section in
                if let title = section.title {
                    Section(header: Text(title)) {
                        sectionItems(section.items)
                    }
                } else {
                    sectionItems(section.items)
                }

                if let footer = section.footer {
                    Section(footer: Text(footer)) {}
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var insetList: some View {
        List {
            ForEach(sections) { section in
                sectionItems(section.items)
            }
        }
        .listStyle(.inset)
    }

    private var insetGroupedList: some View {
        List {
            ForEach(sections) { section in
                if let title = section.title {
                    Section(header: Text(title)) {
                        sectionItems(section.items)
                    }
                } else {
                    sectionItems(section.items)
                }

                if let footer = section.footer {
                    Section(footer: Text(footer)) {}
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var plainList: some View {
        List {
            ForEach(sections) { section in
                sectionItems(section.items)
            }
        }
        .listStyle(.plain)
    }

    private var cardList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(sections) { section in
                    if let title = section.title {
                        Text(title)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    ForEach(section.items) { item in
                        cardItem(item)
                            .drawingGroup()
                    }
                }
            }
            .padding()
        }
    }

    private func sectionItems(_ items: [ListItem]) -> some View {
        ForEach(items) { item in
            if item.isDivider {
                Divider()
            } else {
                listItem(item)
            }
        }
    }

    private func listItem(_ item: ListItem) -> some View {
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

    private func cardItem(_ item: ListItem) -> some View {
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

                // トレーリング要素
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


