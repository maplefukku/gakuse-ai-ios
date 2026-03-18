//
//  CheckboxPickerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-14.
//

import SwiftUI

/// チェックボックスピッカービュー
struct CheckboxPickerView: View {
    let title: String
    let options: [SelectOption]
    @Binding var mutableOptions: [SelectOption]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(options) { option in
                    Button(action: {
                        if let index = options.firstIndex(where: { $0.id == option.id }) {
                            mutableOptions[index].isSelected.toggle()
                        }
                    }) {
                        HStack(spacing: 12) {
                            // チェックボックス
                            Image(systemName: option.isSelected ? "checkmark.square.fill" : "square")
                                .foregroundColor(option.isSelected ? .blue : .secondary)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.label)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                if let subtitle = option.subtitle {
                                    Text(subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            if let icon = option.icon {
                                Image(systemName: icon)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!option.isEnabled)
                    .opacity(option.isEnabled ? 1.0 : 0.5)

                    if option.id != options.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .drawingGroup()
    }
}
