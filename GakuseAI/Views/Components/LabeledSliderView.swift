//
//  LabeledSliderView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

// MARK: - Labeled Slider

/// ラベル付きスライダー
public struct LabeledSliderView: View {
    @Binding private var value: Double
    private let label: String
    private let range: ClosedRange<Double>
    private let step: Double
    private let style: SliderView.SliderStyle
    private let color: Color

    public init(
        value: Binding<Double>,
        label: String,
        range: ClosedRange<Double> = 0...100,
        step: Double = 1,
        style: SliderView.SliderStyle = .standard,
        color: Color = .accentColor
    ) {
        self._value = value
        self.label = label
        self.range = range
        self.step = step
        self.style = style
        self.color = color
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)

                Spacer()

                Text("\(Int(value))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }

            SliderView(
                value: $value,
                range: range,
                step: step,
                style: style,
                color: color,
                showTooltip: false
            )
        }
    }
}

// MARK: - Preview

#Preview("Labeled Slider") {
    VStack(alignment: .leading, spacing: 24) {
        Text("Labeled Slider")
            .font(.headline)

        LabeledSliderView(
            value: .constant(50),
            label: "音量"
        )

        LabeledSliderView(
            value: .constant(75),
            label: "明るさ",
            range: 0...100,
            step: 5
        )

        LabeledSliderView(
            value: .constant(30),
            label: "速度",
            color: .blue
        )
    }
    .padding()
}
