//
//  ListView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

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
                        SectionItems(items: section.items, selectedItem: $selectedItem, useCardStyle: false)
                    }
                } else {
                    SectionItems(items: section.items, selectedItem: $selectedItem, useCardStyle: false)
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
                        SectionItems(items: section.items, selectedItem: $selectedItem, useCardStyle: false)
                    }
                } else {
                    SectionItems(items: section.items, selectedItem: $selectedItem, useCardStyle: false)
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
                SectionItems(items: section.items, selectedItem: $selectedItem, useCardStyle: false)
            }
        }
        .listStyle(.inset)
    }

    private var insetGroupedList: some View {
        List {
            ForEach(sections) { section in
                if let title = section.title {
                    Section(header: Text(title)) {
                        SectionItems(items: section.items, selectedItem: $selectedItem, useCardStyle: false)
                    }
                } else {
                    SectionItems(items: section.items, selectedItem: $selectedItem, useCardStyle: false)
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
                SectionItems(items: section.items, selectedItem: $selectedItem, useCardStyle: false)
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

                    SectionItems(items: section.items, selectedItem: $selectedItem, useCardStyle: true)
                }
            }
            .padding()
        }
    }
}


