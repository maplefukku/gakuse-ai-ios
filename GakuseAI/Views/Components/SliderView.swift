//
//  SliderView.swift
//  GakuseAI
//
//  Created by OpenClaw on 2026-03-09.
//

import SwiftUI

// MARK: - SliderView
/// 汎用スライダーコンポーネント
struct SliderView: View {
    // MARK: - Properties
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let title: String?
    private let minValueLabel: String?
    private let maxValueLabel: String?
    private let color: Color
    private let onEditingChanged: ((Bool) -> Void)?
    
    // MARK: - Initialization
    /// スライダービューを初期化
    /// - Parameters:
    ///   - value: 現在の値
    ///   - range: 値の範囲
    ///   - step: ステップ値（デフォルト: 1.0）
    ///   - title: タイトル（オプション）
    ///   - minValueLabel: 最小値ラベル（オプション）
    ///   - maxValueLabel: 最大値ラベル（オプション）
    ///   - color: アクセントカラー（デフォルト: 青）
    ///   - onEditingChanged: 編集状態変更コールバック
    init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...100,
        step: Double = 1.0,
        title: String? = nil,
        minValueLabel: String? = nil,
        maxValueLabel: String? = nil,
        color: Color = .blue,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.title = title
        self.minValueLabel = minValueLabel
        self.maxValueLabel = maxValueLabel
        self.color = color
        self.onEditingChanged = onEditingChanged
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.primary)
            }
            
            HStack(alignment: .center) {
                if let minValueLabel = minValueLabel {
                    Text(minValueLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .leading)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景トラック
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // プログレストラック
                        Capsule()
                            .fill(color)
                            .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width, height: 8)
                        
                        // スライダーサム
                        Circle()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .fill(color)
                                    .frame(width: 12, height: 12)
                            )
                            .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 12)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let newValue = range.lowerBound + Double(gesture.location.x / geometry.size.width) * (range.upperBound - range.lowerBound)
                                value = snapToStep(newValue, step: step, in: range)
                                onEditingChanged?(true)
                            }
                            .onEnded { _ in
                                onEditingChanged?(false)
                            }
                    )
                }
                .frame(height: 30)
                
                if let maxValueLabel = maxValueLabel {
                    Text(maxValueLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
            
            // 現在の値表示
            HStack {
                Text("\(String(format: "%.0f", value))")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.15))
                    )
                Spacer()
            }
        }
        .padding(.vertical, 4)
        .drawingGroup()
    }
    
    // MARK: - Private Methods
    /// 値をステップに合わせて丸める
    private func snapToStep(_ value: Double, step: Double, in range: ClosedRange<Double>) -> Double {
        let snappedValue = round(value / step) * step
        return min(max(snappedValue, range.lowerBound), range.upperBound)
    }
}

// MARK: - RangeSliderView
/// 範囲スライダーコンポーネント
struct RangeSliderView: View {
    // MARK: - Properties
    @Binding private var lowerValue: Double
    @Binding private var upperValue: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let title: String?
    private let color: Color
    private let onEditingChanged: ((Bool) -> Void)?
    
    // MARK: - Initialization
    /// 範囲スライダービューを初期化
    /// - Parameters:
    ///   - lowerValue: 下限値
    ///   - upperValue: 上限値
    ///   - range: 値の範囲
    ///   - step: ステップ値（デフォルト: 1.0）
    ///   - title: タイトル（オプション）
    ///   - color: アクセントカラー（デフォルト: 青）
    ///   - onEditingChanged: 編集状態変更コールバック
    init(
        lowerValue: Binding<Double>,
        upperValue: Binding<Double>,
        in range: ClosedRange<Double> = 0...100,
        step: Double = 1.0,
        title: String? = nil,
        color: Color = .blue,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.range = range
        self.step = step
        self.title = title
        self.color = color
        self.onEditingChanged = onEditingChanged
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景トラック
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // 範囲トラック
                    Capsule()
                        .fill(color)
                        .frame(
                            width: CGFloat((upperValue - lowerValue) / (range.upperBound - range.lowerBound)) * geometry.size.width,
                            height: 8
                        )
                        .offset(x: CGFloat((lowerValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width)
                    
                    // 下限サム
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .fill(color)
                                .frame(width: 12, height: 12)
                        )
                        .offset(x: CGFloat((lowerValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 12)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let newValue = range.lowerBound + Double(gesture.location.x / geometry.size.width) * (range.upperBound - range.lowerBound)
                                    lowerValue = min(snapToStep(newValue, step: step, in: range), upperValue - step)
                                    onEditingChanged?(true)
                                }
                                .onEnded { _ in
                                    onEditingChanged?(false)
                                }
                        )
                    
                    // 上限サム
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .fill(color)
                                .frame(width: 12, height: 12)
                        )
                        .offset(x: CGFloat((upperValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 12)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let newValue = range.lowerBound + Double(gesture.location.x / geometry.size.width) * (range.upperBound - range.lowerBound)
                                    upperValue = max(snapToStep(newValue, step: step, in: range), lowerValue + step)
                                    onEditingChanged?(true)
                                }
                                .onEnded { _ in
                                    onEditingChanged?(false)
                                }
                        )
                }
                .contentShape(Rectangle())
            }
            .frame(height: 40)
            
            // 現在の値表示
            HStack {
                Text("\(String(format: "%.0f", lowerValue))")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.15))
                    )
                
                Spacer()
                
                Text("\(String(format: "%.0f", upperValue))")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.15))
                    )
            }
        }
        .padding(.vertical, 4)
        .drawingGroup()
    }
    
    // MARK: - Private Methods
    /// 値をステップに合わせて丸める
    private func snapToStep(_ value: Double, step: Double, in range: ClosedRange<Double>) -> Double {
        let snappedValue = round(value / step) * step
        return min(max(snappedValue, range.lowerBound), range.upperBound)
    }
}

// MARK: - StepperSliderView
/// ステッパー付きスライダーコンポーネント
struct StepperSliderView: View {
    // MARK: - Properties
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let title: String?
    private let color: Color
    private let onValueChanged: ((Double) -> Void)?
    @State private var isEditing: Bool = false
    
    // MARK: - Initialization
    /// ステッパー付きスライダービューを初期化
    /// - Parameters:
    ///   - value: 現在の値
    ///   - range: 値の範囲
    ///   - step: ステップ値（デフォルト: 1.0）
    ///   - title: タイトル（オプション）
    ///   - color: アクセントカラー（デフォルト: 青）
    ///   - onValueChanged: 値変更コールバック
    init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...100,
        step: Double = 1.0,
        title: String? = nil,
        color: Color = .blue,
        onValueChanged: ((Double) -> Void)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.title = title
        self.color = color
        self.onValueChanged = onValueChanged
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.primary)
            }
            
            HStack(spacing: 16) {
                // 減少ボタン
                Button(action: {
                    let newValue = max(value - step, range.lowerBound)
                    value = newValue
                    onValueChanged?(newValue)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(value > range.lowerBound ? color : .gray.opacity(0.3))
                        .symbolEffect(.pulse, options: .repeating, isActive: isEditing && value > range.lowerBound)
                }
                .disabled(value <= range.lowerBound)
                .buttonStyle(ScaleButtonStyle(scale: 0.9))
                
                // スライダー
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景トラック
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // プログレストラック
                        Capsule()
                            .fill(color)
                            .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width, height: 8)
                        
                        // スライダーサム
                        Circle()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .fill(color)
                                    .frame(width: 12, height: 12)
                            )
                            .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 12)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                isEditing = true
                                let newValue = range.lowerBound + Double(gesture.location.x / geometry.size.width) * (range.upperBound - range.lowerBound)
                                value = snapToStep(newValue, step: step, in: range)
                            }
                            .onEnded { _ in
                                isEditing = false
                                onValueChanged?(value)
                            }
                    )
                }
                .frame(height: 30)
                
                // 増加ボタン
                Button(action: {
                    let newValue = min(value + step, range.upperBound)
                    value = newValue
                    onValueChanged?(newValue)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(value < range.upperBound ? color : .gray.opacity(0.3))
                        .symbolEffect(.pulse, options: .repeating, isActive: isEditing && value < range.upperBound)
                }
                .disabled(value >= range.upperBound)
                .buttonStyle(ScaleButtonStyle(scale: 0.9))
            }
            
            // 現在の値表示
            HStack {
                Text("\(String(format: "%.0f", value))")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.15))
                    )
                Spacer()
            }
        }
        .padding(.vertical, 4)
        .drawingGroup()
    }
    
    // MARK: - Private Methods
    /// 値をステップに合わせて丸める
    private func snapToStep(_ value: Double, step: Double, in range: ClosedRange<Double>) -> Double {
        let snappedValue = round(value / step) * step
        return min(max(snappedValue, range.lowerBound), range.upperBound)
    }
}

// MARK: - SwiftUI Previews
#Preview("SliderView - Basic") {
    VStack(spacing: 20) {
        SliderView(
            value: .constant(50),
            title: "音量",
            minValueLabel: "0",
            maxValueLabel: "100"
        )
        
        SliderView(
            value: .constant(75),
            in: 0...10,
            step: 0.5,
            title: "明るさ",
            minValueLabel: "暗い",
            maxValueLabel: "明るい",
            color: .orange
        )
    }
    .padding()
}

#Preview("SliderView - Color Variations") {
    VStack(spacing: 20) {
        SliderView(
            value: .constant(60),
            title: "青色",
            color: .blue
        )
        
        SliderView(
            value: .constant(60),
            title: "緑色",
            color: .green
        )
        
        SliderView(
            value: .constant(60),
            title: "赤色",
            color: .red
        )
        
        SliderView(
            value: .constant(60),
            title: "紫",
            color: .purple
        )
    }
    .padding()
}

#Preview("RangeSliderView") {
    VStack(spacing: 20) {
        RangeSliderView(
            lowerValue: .constant(30),
            upperValue: .constant(70),
            title: "年齢範囲"
        )
        
        RangeSliderView(
            lowerValue: .constant(10000),
            upperValue: .constant(50000),
            in: 0...100000,
            step: 5000,
            title: "価格範囲（円）",
            color: .green
        )
    }
    .padding()
}

#Preview("StepperSliderView") {
    VStack(spacing: 20) {
        StepperSliderView(
            value: .constant(50),
            title: "数量"
        )
        
        StepperSliderView(
            value: .constant(5),
            in: 1...10,
            step: 1,
            title: "レベル",
            color: .orange
        )
    }
    .padding()
}

// MARK: - ScaleButtonStyle
/// スケールアニメーション付きボタンスタイル
struct ScaleButtonStyle: ButtonStyle {
    let scale: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
