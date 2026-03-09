//
//  Slider.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-09.
//

import SwiftUI

// MARK: - Custom Slider
struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...100
    var style: SliderStyle = .standard
    var step: Double = 0
    var showsValue: Bool = false
    var valueFormatter: ((Double) -> String)? = nil

    @State private var isDragging: Bool = false
    @State private var dragOffset: CGFloat = 0

    private var totalRange: Double {
        range.upperBound - range.lowerBound
    }

    private var normalizedValue: Double {
        (value - range.lowerBound) / totalRange
    }

    private func valueLabel(_ val: Double) -> String {
        if let formatter = valueFormatter {
            return formatter(val)
        }
        return String(format: "%.0f", val)
    }

    var body: some View {
        VStack(spacing: style == .minimal ? 4 : 8) {
            // 値表示（オプション）
            if showsValue {
                Text(valueLabel(value))
                    .font(.system(size: style.valueFontSize, weight: .semibold))
                    .foregroundColor(style.valueColor)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: value)
            }

            // スライダー本体
            ZStack(alignment: .leading) {
                // トラック（背景）
                trackView

                // トラック（進行済み）
                progressView

                // つまみ
                thumbView
                    .offset(x: thumbOffset)
            }
            .frame(height: style.trackHeight)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        updateValue(from: value.location.x)
                    }
                    .onEnded { _ in
                        isDragging = false
                        // タップフィードバック
                        let feedback = UIImpactFeedbackGenerator(style: .light)
                        feedback.impactOccurred()
                    }
            )
            .pressEvents(
                onPressBegin: { isDragging = true },
                onPressEnd: { isDragging = false }
            )
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isDragging)
    }

    @ViewBuilder
    private var trackView: some View {
        RoundedRectangle(cornerRadius: style.cornerRadius)
            .fill(style.trackColor)
            .frame(height: style.trackHeight)
    }

    @ViewBuilder
    private var progressView: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(style.progressColor)
                .frame(width: geometry.size.width * normalizedValue, height: style.trackHeight)
        }
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
    }

    @ViewBuilder
    private var thumbView: some View {
        ZStack {
            // つまみ本体
            Circle()
                .fill(style.thumbColor)
                .frame(width: style.thumbSize, height: style.thumbSize)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)

            // つまみのハイライト
            if style.showsThumbHighlight {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: style.thumbSize * 0.4, height: style.thumbSize * 0.4)
                    .offset(y: -style.thumbSize * 0.15)
            }
        }
        .scaleEffect(isDragging ? style.dragScale : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isDragging)
    }

    private var thumbOffset: CGFloat {
        // GeometryReaderがないため、計算を簡略化
        0
    }

    private func updateValue(from location: CGFloat) {
        // トラックの幅を取得（簡略化のため100として計算）
        let trackWidth: CGFloat = 300
        let percentage = max(0, min(1, location / trackWidth))
        var newValue = range.lowerBound + (percentage * totalRange)

        // ステップがある場合はステップに合わせる
        if step > 0 {
            newValue = round(newValue / step) * step
        }

        value = max(range.lowerBound, min(range.upperBound, newValue))
    }
}

// MARK: - Range Slider
struct RangeSlider: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    var range: ClosedRange<Double> = 0...100
    var step: Double = 0
    var style: SliderStyle = .standard

    @State private var isDraggingLower: Bool = false
    @State private var isDraggingUpper: Bool = false

    private var totalRange: Double {
        range.upperBound - range.lowerBound
    }

    private var normalizedLower: Double {
        (lowerValue - range.lowerBound) / totalRange
    }

    private var normalizedUpper: Double {
        (upperValue - range.lowerBound) / totalRange
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                // トラック（背景）
                trackView

                // トラック（選択範囲）
                rangeView

                // 下限のつまみ
                thumbView(isDragging: isDraggingLower)
                    .offset(x: thumbOffset(normalizedLower))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDraggingLower = true
                                updateLowerValue(from: value.location.x)
                            }
                            .onEnded { _ in
                                isDraggingLower = false
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                            }
                    )

                // 上限のつまみ
                thumbView(isDragging: isDraggingUpper)
                    .offset(x: thumbOffset(normalizedUpper))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDraggingUpper = true
                                updateUpperValue(from: value.location.x)
                            }
                            .onEnded { _ in
                                isDraggingUpper = false
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                            }
                    )
            }
            .frame(height: style.trackHeight)

            // 値表示
            HStack {
                Text("\(Int(lowerValue))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(upperValue))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var trackView: some View {
        RoundedRectangle(cornerRadius: style.cornerRadius)
            .fill(style.trackColor)
            .frame(height: style.trackHeight)
    }

    @ViewBuilder
    private var rangeView: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(style.progressColor)
                .frame(
                    width: geometry.size.width * (normalizedUpper - normalizedLower),
                    height: style.trackHeight
                )
                .offset(x: geometry.size.width * normalizedLower)
        }
    }

    @ViewBuilder
    private func thumbView(isDragging: Bool) -> some View {
        Circle()
            .fill(style.thumbColor)
            .frame(width: style.thumbSize, height: style.thumbSize)
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            .scaleEffect(isDragging ? style.dragScale : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isDragging)
    }

    private func thumbOffset(_ normalized: Double) -> CGFloat {
        0 // 簡略化
    }

    private func updateLowerValue(from location: CGFloat) {
        let trackWidth: CGFloat = 300
        let percentage = max(0, min(1, location / trackWidth))
        var newValue = range.lowerBound + (percentage * totalRange)

        if step > 0 {
            newValue = round(newValue / step) * step
        }

        lowerValue = max(range.lowerBound, min(upperValue - 10, newValue))
    }

    private func updateUpperValue(from location: CGFloat) {
        let trackWidth: CGFloat = 300
        let percentage = max(0, min(1, location / trackWidth))
        var newValue = range.lowerBound + (percentage * totalRange)

        if step > 0 {
            newValue = round(newValue / step) * step
        }

        upperValue = max(lowerValue + 10, min(range.upperBound, newValue))
    }
}

// MARK: - Slider Style
enum SliderStyle {
    case standard
    case minimal
    case filled
    case rounded

    var trackHeight: CGFloat {
        switch self {
        case .standard:
            return 6
        case .minimal:
            return 4
        case .filled:
            return 8
        case .rounded:
            return 10
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .standard:
            return 3
        case .minimal:
            return 2
        case .filled:
            return 4
        case .rounded:
            return 5
        }
    }

    var trackColor: Color {
        switch self {
        case .standard:
            return Color(.systemGray5)
        case .minimal:
            return Color(.systemGray4)
        case .filled:
            return Color(.systemGray6)
        case .rounded:
            return Color(.systemGray5)
        }
    }

    var progressColor: Color {
        switch self {
        case .standard:
            return Color.accentColor
        case .minimal:
            return Color.accentColor
        case .filled:
            return Color.accentColor
        case .rounded:
            return Color.accentColor
        }
    }

    var thumbSize: CGFloat {
        switch self {
        case .standard:
            return 24
        case .minimal:
            return 20
        case .filled:
            return 28
        case .rounded:
            return 32
        }
    }

    var thumbColor: Color {
        switch self {
        case .standard:
            return Color(.systemBackground)
        case .minimal:
            return Color.accentColor
        case .filled:
            return Color.accentColor
        case .rounded:
            return Color.accentColor
        }
    }

    var dragScale: CGFloat {
        switch self {
        case .standard:
            return 1.1
        case .minimal:
            return 1.0
        case .filled:
            return 1.15
        case .rounded:
            return 1.2
        }
    }

    var showsThumbHighlight: Bool {
        switch self {
        case .standard:
            return true
        case .minimal:
            return false
        case .filled:
            return true
        case .rounded:
            return true
        }
    }

    var valueFontSize: CGFloat {
        switch self {
        case .standard:
            return 16
        case .minimal:
            return 14
        case .filled:
            return 18
        case .rounded:
            return 20
        }
    }

    var valueColor: Color {
        switch self {
        case .standard:
            return .primary
        case .minimal:
            return .secondary
        case .filled:
            return .primary
        case .rounded:
            return .primary
        }
    }
}

// MARK: - Press Events Modifier
struct PressEventsModifier: ViewModifier {
    var onPressBegin: () -> Void
    var onPressEnd: () -> Void

    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            onPressBegin()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onPressEnd()
                    }
            )
    }
}

extension View {
    func pressEvents(
        onPressBegin: @escaping () -> Void = {},
        onPressEnd: @escaping () -> Void = {}
    ) -> some View {
        modifier(PressEventsModifier(onPressBegin: onPressBegin, onPressEnd: onPressEnd))
    }
}

// MARK: - SwiftUI Previews
#Preview("Standard Slider") {
    VStack(spacing: 30) {
        Text("標準スライダー")
            .font(.headline)

        CustomSlider(
            value: .constant(50),
            range: 0...100,
            style: .standard,
            showsValue: true
        )

        CustomSlider(
            value: .constant(75),
            range: 0...100,
            style: .standard,
            step: 10,
            showsValue: true
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Minimal Slider") {
    VStack(spacing: 30) {
        Text("ミニマルスライダー")
            .font(.headline)

        CustomSlider(
            value: .constant(30),
            range: 0...100,
            style: .minimal,
            showsValue: true
        )

        CustomSlider(
            value: .constant(80),
            range: 0...100,
            style: .minimal,
            step: 5,
            showsValue: false
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Filled Slider") {
    VStack(spacing: 30) {
        Text("フィルドスライダー")
            .font(.headline)

        CustomSlider(
            value: .constant(60),
            range: 0...100,
            style: .filled,
            showsValue: true
        )

        CustomSlider(
            value: .constant(90),
            range: 0...100,
            style: .filled,
            step: 20,
            showsValue: true
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Rounded Slider") {
    VStack(spacing: 30) {
        Text("ラウンドスライダー")
            .font(.headline)

        CustomSlider(
            value: .constant(40),
            range: 0...100,
            style: .rounded,
            showsValue: true
        )

        CustomSlider(
            value: .constant(70),
            range: 0...100,
            style: .rounded,
            step: 15,
            showsValue: true
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Range Slider") {
    VStack(spacing: 30) {
        Text("レンジスライダー")
            .font(.headline)

        RangeSlider(
            lowerValue: .constant(30),
            upperValue: .constant(70),
            range: 0...100,
            style: .standard
        )

        RangeSlider(
            lowerValue: .constant(20),
            upperValue: .constant(50),
            range: 0...100,
            step: 10,
            style: .rounded
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Custom Value Formatter") {
    VStack(spacing: 30) {
        Text("カスタム値フォーマット")
            .font(.headline)

        CustomSlider(
            value: .constant(50),
            range: 0...100,
            style: .standard,
            showsValue: true,
            valueFormatter: { value in
                "\(Int(value))%"
            }
        )

        CustomSlider(
            value: .constant(0.75),
            range: 0...1,
            style: .filled,
            step: 0.1,
            showsValue: true,
            valueFormatter: { value in
                String(format: "%.1f", value)
            }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Various Ranges") {
    VStack(spacing: 30) {
        Text("様々な範囲")
            .font(.headline)

        CustomSlider(
            value: .constant(5),
            range: 0...10,
            style: .standard,
            showsValue: true
        )

        CustomSlider(
            value: .constant(25),
            range: -50...50,
            style: .standard,
            showsValue: true
        )

        CustomSlider(
            value: .constant(0.5),
            range: 0...1,
            style: .filled,
            step: 0.1,
            showsValue: true,
            valueFormatter: { value in
                String(format: "%.1f", value)
            }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
