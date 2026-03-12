//
//  RangeSliderView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

// MARK: - Range Slider

/// 範囲スライダー
public struct RangeSliderView: View {
    @Binding private var lowerValue: Double
    @Binding private var upperValue: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let color: Color

    public init(
        lowerValue: Binding<Double>,
        upperValue: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        step: Double = 1,
        color: Color = .accentColor
    ) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.range = range
        self.step = step
        self.color = color
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // トラック背景
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(height: 8)

                // 塗りつぶされたトラック
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(
                        width: upperThumbPosition(geometry: geometry) - lowerThumbPosition(geometry: geometry),
                        height: 8
                    )
                    .offset(x: lowerThumbPosition(geometry: geometry))

                // 下限ノブ
                Circle()
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .stroke(color, lineWidth: 2)
                    )
                    .frame(width: 24, height: 24)
                    .position(
                        x: lowerThumbPosition(geometry: geometry),
                        y: geometry.size.height / 2
                    )
                    .gesture(
                        dragGesture(geometry: geometry, isLowerThumb: true)
                    )

                // 上限ノブ
                Circle()
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .stroke(color, lineWidth: 2)
                    )
                    .frame(width: 24, height: 24)
                    .position(
                        x: upperThumbPosition(geometry: geometry),
                        y: geometry.size.height / 2
                    )
                    .gesture(
                        dragGesture(geometry: geometry, isLowerThumb: false)
                    )
            }
        }
        .frame(height: 44)
        .drawingGroup()
    }

    // MARK: - Computed Properties

    private func normalizedValue(_ value: Double) -> CGFloat {
        let normalized = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(normalized)
    }

    private func lowerThumbPosition(geometry: GeometryProxy) -> CGFloat {
        geometry.size.width * normalizedValue(lowerValue)
    }

    private func upperThumbPosition(geometry: GeometryProxy) -> CGFloat {
        geometry.size.width * normalizedValue(upperValue)
    }

    private func snapToStep(_ rawValue: Double) -> Double {
        let snapped = round(rawValue / step) * step
        return min(max(snapped, range.lowerBound), range.upperBound)
    }

    // MARK: - Drag Gesture

    private func dragGesture(geometry: GeometryProxy, isLowerThumb: Bool) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let newValue = snapToStep(
                    range.lowerBound + Double(value.location.x / geometry.size.width) * (range.upperBound - range.lowerBound)
                )

                if isLowerThumb {
                    lowerValue = min(newValue, upperValue - step)
                } else {
                    upperValue = max(newValue, lowerValue + step)
                }
            }
    }
}

// MARK: - Preview

#Preview("Range Slider") {
    VStack(alignment: .leading, spacing: 24) {
        Text("Range Slider")
            .font(.headline)

        RangeSliderView(
            lowerValue: .constant(25),
            upperValue: .constant(75)
        )

        RangeSliderView(
            lowerValue: .constant(40),
            upperValue: .constant(60),
            color: .blue
        )

        RangeSliderView(
            lowerValue: .constant(10),
            upperValue: .constant(90),
            step: 10
        )
    }
    .padding()
}
