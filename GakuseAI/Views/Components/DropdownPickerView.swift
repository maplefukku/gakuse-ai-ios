//
//  DropdownPickerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-14.
//

import SwiftUI

/// ドロップダウンピッカービュー
struct DropdownPickerView: View {
    let title: String
    let options: [SelectOption]
    @Binding var selectedValue: String
    @Binding var isDropdownOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            Button(action: {
                isDropdownOpen.toggle()
            }) {
                HStack {
                    Text(selectedOption?.label ?? "選択してください")
                        .foregroundColor(selectedOption != nil ? .primary : .secondary)

                    Spacer()

                    Image(systemName: isDropdownOpen ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: isDropdownOpen ? 2 : 0)
                )
            }
            .buttonStyle(.plain)

            if isDropdownOpen {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(options.filter { $0.isEnabled }) { option in
                        Button(action: {
                            selectedValue = option.value
                            isDropdownOpen = false
                        }) {
                            HStack {
                                if let icon = option.icon {
                                    Image(systemName: icon)
                                        .foregroundColor(.secondary)
                                }

                                Text(option.label)
                                    .foregroundColor(.primary)

                                Spacer()

                                if selectedValue == option.value {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(selectedValue == option.value ? Color.blue.opacity(0.1) : Color.clear)
                        }
                        .buttonStyle(.plain)

                        if option.id != options.last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .transition(.opacity)
            }
        }
        .drawingGroup()
    }

    private var selectedOption: SelectOption? {
        options.first { $0.value == selectedValue }
    }
}
