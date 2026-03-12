//
//  SelectView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

/// 選択スタイル
enum SelectStyle {
    case standard     // 標準選択（ピッカー）
    case dropdown     // ドロップダウン選択
    case segmented    // セグメント選択
    case radio        // ラジオボタン選択
    case checkbox     // チェックボックス選択（複数選択）
    case card         // カード選択
}

/// 選択肢
struct SelectOption: Identifiable, Hashable, Equatable {
    let id = UUID()
    var label: String
    var value: String
    var icon: String?
    var subtitle: String?
    var isEnabled: Bool = true
    var isSelected: Bool = false

    static func == (lhs: SelectOption, rhs: SelectOption) -> Bool {
        lhs.id == rhs.id
    }
}

/// メイン選択ビュー
struct SelectView: View {
    let title: String
    let options: [SelectOption]
    let style: SelectStyle
    @Binding var selectedValue: String
    @State private var isDropdownOpen: Bool = false
    @State private var mutableOptions: [SelectOption] = []

    var body: some View {
        Group {
            switch style {
            case .standard:
                standardPicker
            case .dropdown:
                dropdownPicker
            case .segmented:
                segmentedPicker
            case .radio:
                radioPicker
            case .checkbox:
                checkboxPicker
            case .card:
                cardPicker
            }
        }
        .onAppear {
            mutableOptions = options
        }
    }

    private var standardPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            Picker(title, selection: $selectedValue) {
                ForEach(mutableOptions.filter { $0.isEnabled }) { option in
                    Text(option.label)
                        .tag(option.value)
                }
            }
            .pickerStyle(.wheel)
        }
    }

    private var dropdownPicker: some View {
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
                    ForEach(mutableOptions.filter { $0.isEnabled }) { option in
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

    private var segmentedPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            Picker(title, selection: $selectedValue) {
                ForEach(mutableOptions.filter { $0.isEnabled }) { option in
                    Text(option.label)
                        .tag(option.value)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var radioPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(mutableOptions.filter { $0.isEnabled }) { option in
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

    private var checkboxPicker: some View {
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

    private var cardPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(mutableOptions.filter { $0.isEnabled }) { option in
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

    private var selectedOption: SelectOption? {
        options.first { $0.value == selectedValue }
    }
}

/// シンプル選択ビュー
struct SimpleSelectView: View {
    let options: [SelectOption]
    @Binding var selectedValue: String

    var body: some View {
        SelectView(
            title: "",
            options: options,
            style: .standard,
            selectedValue: $selectedValue
        )
    }
}

/// ドロップダウン選択ビュー
struct DropdownSelectView: View {
    let title: String
    let options: [SelectOption]
    @Binding var selectedValue: String

    var body: some View {
        SelectView(
            title: title,
            options: options,
            style: .dropdown,
            selectedValue: $selectedValue
        )
    }
}

/// ラジオ選択ビュー
struct RadioSelectView: View {
    let title: String
    let options: [SelectOption]
    @Binding var selectedValue: String

    var body: some View {
        SelectView(
            title: title,
            options: options,
            style: .radio,
            selectedValue: $selectedValue
        )
    }
}

/// カード選択ビュー
struct CardSelectView: View {
    let options: [SelectOption]
    @Binding var selectedValue: String

    var body: some View {
        SelectView(
            title: "",
            options: options,
            style: .card,
            selectedValue: $selectedValue
        )
    }
}


