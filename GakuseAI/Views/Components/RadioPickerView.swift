//
//  RadioPickerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-14.
//

import SwiftUI

/// ラジオピッカービュー
struct RadioPickerView: View {
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

            VStack(alignment: .leading, spacing: 8) {
                ForEach(options.filter { $0.isEnabled }) { option in
                    Button(action: {
                        selectedValue = option.value
                    }) {
                        HStack(spacing: 12) {
                            // ラジオボタン
                            ZStack {
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: 20, height: 20)

                                if selectedValue == option.value {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 10, height: 10)
                                }
                            }

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

                    if option.id != options.filter({ $0.isEnabled }).last?.id {
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
