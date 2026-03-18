//
//  SelectView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// SelectStyleとSelectOptionはSelectStyle.swiftで定義

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
        DropdownPickerView(
            title: title,
            options: mutableOptions,
            selectedValue: $selectedValue,
            isDropdownOpen: $isDropdownOpen
        )
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
        RadioPickerView(
            title: title,
            options: mutableOptions,
            selectedValue: $selectedValue
        )
    }

    private var checkboxPicker: some View {
        CheckboxPickerView(
            title: title,
            options: options,
            mutableOptions: $mutableOptions
        )
    }

    private var cardPicker: some View {
        CardPickerView(
            title: title,
            options: mutableOptions,
            selectedValue: $selectedValue
        )
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


