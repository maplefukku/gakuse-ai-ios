//
//  CardPickerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-14.
//

import SwiftUI

/// カードピッカービュー
struct CardPickerView: View {
    let title: String
    let options: [SelectOption]
    @Binding var selectedValue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(options.filter { $0.isEnabled }) { option in
                        Button(action: {
                            selectedValue = option.value
                        }) {
                            VStack(spacing: 8) {
                                if let icon = option.icon {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedValue == option.value ? .white : .primary)
                                }

                                Text(option.label)
                                    .font(.caption)
                                    .foregroundColor(selectedValue == option.value ? .white : .primary)
                            }
                            .frame(width: 80, height: 60)
                            .background(selectedValue == option.value ? Color.blue : Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedValue == option.value ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
        .drawingGroup()
    }
}
