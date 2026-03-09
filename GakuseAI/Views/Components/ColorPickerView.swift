//
//  ColorPickerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// MARK: - Color Picker View

/// カラーピッカーコンポーネント
///
/// - プリセットカラー
/// - カスタムカラー選択
/// - 複数のスタイル: standard, minimal, grid
public struct ColorPickerView: View {
    @Binding private var selectedColor: Color
    private let presetColors: [PresetColor]
    private let style: PickerStyle
    private let columns: Int
    private let showCustomPicker: Bool
    private let onColorChange: ((Color) -> Void)?
    
    @State private var isShowingCustomPicker: Bool = false
    
    public enum PickerStyle {
        case standard
        case minimal
        case grid
    }
    
    public struct PresetColor: Identifiable, Equatable {
        public let id = UUID()
        public let color: Color
        public let name: String?
        
        public init(color: Color, name: String? = nil) {
            self.color = color
            self.name = name
        }
        
        public static func == (lhs: PresetColor, rhs: PresetColor) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    /// カラーピッカービューを初期化
    /// - Parameters:
    ///   - selectedColor: 選択された色
    ///   - presetColors: プリセットカラーの配列
    ///   - style: ピッカーのスタイル（デフォルト: standard）
    ///   - columns: グリッドの列数（デフォルト: 5）
    ///   - showCustomPicker: カスタムピッカーを表示するか（デフォルト: true）
    ///   - onColorChange: 色変更時のコールバック
    public init(
        selectedColor: Binding<Color>,
        presetColors: [PresetColor] = Self.defaultPresetColors,
        style: PickerStyle = .standard,
        columns: Int = 5,
        showCustomPicker: Bool = true,
        onColorChange: ((Color) -> Void)? = nil
    ) {
        self._selectedColor = selectedColor
        self.presetColors = presetColors
        self.style = style
        self.columns = columns
        self.showCustomPicker = showCustomPicker
        self.onColorChange = onColorChange
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            switch style {
            case .standard:
                standardLayout
            case .minimal:
                minimalLayout
            case .grid:
                gridLayout
            }
            
            if showCustomPicker {
                customPickerButton
            }
        }
        .drawingGroup()
        .sheet(isPresented: $isShowingCustomPicker) {
            customColorPickerSheet
        }
    }
    
    // MARK: - Layouts
    
    @ViewBuilder
    private var standardLayout: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(presetColors) { preset in
                    colorButton(for: preset)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private var minimalLayout: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(presetColors) { preset in
                    minimalColorButton(for: preset)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private var gridLayout: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: columns),
            spacing: 12
        ) {
            ForEach(presetColors) { preset in
                colorButton(for: preset)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Color Button
    
    @ViewBuilder
    private func colorButton(for preset: PresetColor) -> some View {
        Button(action: {
            selectedColor = preset.color
            onColorChange?(preset.color)
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
        }) {
            VStack(spacing: 4) {
                Circle()
                    .fill(preset.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(selectedColor == preset.color ? Color.primary : Color.clear, lineWidth: 3)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                
                if let name = preset.name {
                    Text(name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func minimalColorButton(for preset: PresetColor) -> some View {
        Button(action: {
            selectedColor = preset.color
            onColorChange?(preset.color)
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
        }) {
            Circle()
                .fill(preset.color)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(selectedColor == preset.color ? Color.primary : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Custom Picker
    
    @ViewBuilder
    private var customPickerButton: some View {
        Button(action: {
            isShowingCustomPicker = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.secondary)
                
                Text("カスタムカラー")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var customColorPickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                // カラー選択
                ColorPicker("", selection: $selectedColor)
                    .labelsHidden()
                    .frame(height: 100)
                
                // 選択した色のプレビュー
                VStack(spacing: 8) {
                    Text("選択した色")
                        .font(.headline)
                    
                    Rectangle()
                        .fill(selectedColor)
                        .frame(height: 60)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text(selectedColor.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("カスタムカラー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        isShowingCustomPicker = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("選択") {
                        onColorChange?(selectedColor)
                        isShowingCustomPicker = false
                    }
                }
            }
        }
        .drawingGroup()
    }
    
    // MARK: - Default Preset Colors
    
    public static var defaultPresetColors: [PresetColor] {
        [
            PresetColor(color: .red, name: "レッド"),
            PresetColor(color: .orange, name: "オレンジ"),
            PresetColor(color: .yellow, name: "イエロー"),
            PresetColor(color: .green, name: "グリーン"),
            PresetColor(color: .blue, name: "ブルー"),
            PresetColor(color: .purple, name: "パープル"),
            PresetColor(color: .pink, name: "ピンク"),
            PresetColor(color: .cyan, name: "シアン"),
            PresetColor(color: .indigo, name: "インディゴ"),
            PresetColor(color: .mint, name: "ミント"),
            PresetColor(color: .teal, name: "ティール"),
            PresetColor(color: .brown, name: "ブラウン"),
            PresetColor(color: .gray, name: "グレー"),
            PresetColor(color: .black, name: "ブラック"),
            PresetColor(color: .white, name: "ホワイト")
        ]
    }
}

// MARK: - Compact Color Picker

/// コンパクトなカラーピッカー
public struct CompactColorPickerView: View {
    @Binding private var selectedColor: Color
    private let presetColors: [ColorPickerView.PresetColor]
    private let columns: Int
    
    @State private var isPressed: UUID? = nil
    
    public init(
        selectedColor: Binding<Color>,
        presetColors: [ColorPickerView.PresetColor] = ColorPickerView.defaultPresetColors,
        columns: Int = 6
    ) {
        self._selectedColor = selectedColor
        self.presetColors = presetColors
        self.columns = columns
    }
    
    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns),
            spacing: 8
        ) {
            ForEach(presetColors) { preset in
                colorButton(for: preset)
            }
        }
        .drawingGroup()
    }
    
    @ViewBuilder
    private func colorButton(for preset: ColorPickerView.PresetColor) -> some View {
        Button(action: {
            selectedColor = preset.color
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
        }) {
            Circle()
                .fill(preset.color)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(selectedColor == preset.color ? Color.primary : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed == preset.id ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = preset.id
                }
                .onEnded { _ in
                    isPressed = nil
                }
        )
    }
}

// MARK: - Previews

#Preview("Standard Style") {
    VStack(alignment: .leading, spacing: 20) {
        Text("Standard Style")
            .font(.headline)
        
        ColorPickerView(
            selectedColor: .constant(.blue),
            presetColors: ColorPickerView.defaultPresetColors,
            style: .standard
        )
        
        Text("Selected Color")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}

#Preview("Minimal Style") {
    VStack(alignment: .leading, spacing: 20) {
        Text("Minimal Style")
            .font(.headline)
        
        ColorPickerView(
            selectedColor: .constant(.green),
            presetColors: ColorPickerView.defaultPresetColors,
            style: .minimal
        )
    }
    .padding()
}

#Preview("Grid Style") {
    VStack(alignment: .leading, spacing: 20) {
        Text("Grid Style")
            .font(.headline)
        
        ColorPickerView(
            selectedColor: .constant(.purple),
            presetColors: ColorPickerView.defaultPresetColors,
            style: .grid,
            columns: 5
        )
    }
    .padding()
}

#Preview("Compact") {
    VStack(alignment: .leading, spacing: 20) {
        Text("Compact Color Picker")
            .font(.headline)
        
        CompactColorPickerView(
            selectedColor: .constant(.orange)
        )
    }
    .padding()
}

#Preview("Binding Example") {
    struct ColorPickerExample: View {
        @State private var selectedColor: Color = .blue
        
        var body: some View {
            VStack(spacing: 30) {
                ColorPickerView(
                    selectedColor: $selectedColor,
                    onColorChange: { color in
                        print("Color changed: \(color)")
                    }
                )
                
                Rectangle()
                    .fill(selectedColor)
                    .frame(height: 100)
                    .cornerRadius(12)
                    .overlay(
                        Text(selectedColor.description)
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            }
            .padding()
        }
    }
    
    return ColorPickerExample()
}
