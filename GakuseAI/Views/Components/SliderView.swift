//
//  SliderView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// MARK: - Slider View

/// スライダーコンポーネント
///
/// - カスタマイズ可能なスタイル
/// - ステップ（間隔）対応
/// - ツールチップ表示オプション
public struct SliderView: View {
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let style: SliderStyle
    private let color: Color
    private let showTooltip: Bool
    private let onValueChanged: ((Double) -> Void)?

    public enum SliderStyle {
        case standard
        case minimal
        case filled
    }

    /// スライダービューを初期化
    /// - Parameters:
    ///   - value: スライダーの値（バインディング）
    ///   - range: 値の範囲（デフォルト: 0...100）
    ///   - step: ステップ値（デフォルト: 1）
    ///   - style: スライダーのスタイル（デフォルト: standard）
    ///   - color: スライダーの色（デフォルト: アクセントカラー）
    ///   - showTooltip: ツールチップ表示（デフォルト: true）
    ///   - onValueChanged: 値変更時のコールバック
    public init(
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        step: Double = 1,
        style: SliderStyle = .standard,
        color: Color = .accentColor,
        showTooltip: Bool = true,
        onValueChanged: ((Double) -> Void)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.style = style
        self.color = color
        self.showTooltip = showTooltip
        self.onValueChanged = onValueChanged
    }

    public var body: some View {
        VStack(spacing: 12) {
            sliderContent

            if showTooltip {
                valueText
            }
        }
        .drawingGroup()
    }

    // MARK: - Slider Content

    @ViewBuilder
    private var sliderContent: some View {
        switch style {
        case .standard:
            standardSlider
        case .minimal:
            minimalSlider
        case .filled:
            filledSlider
        }
    }

    @ViewBuilder
    private var standardSlider: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // トラック背景
                trackBackground

                // 塗りつぶされたトラック
                filledTrack(geometry: geometry)

                // ノブ
                thumb(geometry: geometry)
            }
            .gesture(dragGesture(geometry: geometry))
        }
        .frame(height: 44)
    }

    @ViewBuilder
    private var minimalSlider: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // トラック背景
                Capsule()
                    .fill(Color(.separator))
                    .frame(height: 4)

                // 塗りつぶされたトラック
                Capsule()
                    .fill(color)
                    .frame(width: trackWidth(geometry: geometry), height: 4)

                // ノブ
                thumb(geometry: geometry)
            }
            .gesture(dragGesture(geometry: geometry))
        }
        .frame(height: 44)
    }

    @ViewBuilder
    private var filledSlider: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // トラック背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 12)

                // 塗りつぶされたトラック
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: trackWidth(geometry: geometry), height: 12)

                // ノブ
                thumb(geometry: geometry)
            }
            .gesture(dragGesture(geometry: geometry))
        }
        .frame(height: 44)
    }

    // MARK: - Track Background

    @ViewBuilder
    private var trackBackground: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(.systemGray6))
            .frame(height: 8)
    }

    // MARK: - Filled Track

    @ViewBuilder
    private func filledTrack(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: trackWidth(geometry: geometry), height: 8)
    }

    // MARK: - Thumb

    @ViewBuilder
    private func thumb(geometry: GeometryProxy) -> some View {
        Circle()
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
            )
            .frame(width: thumbSize, height: thumbSize)
            .position(
                x: thumbPosition(geometry: geometry),
                y: geometry.size.height / 2
            )
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isDragging)
    }

    // MARK: - Value Text

    @ViewBuilder
    private var valueText: some View {
        Text("\(Int(value))")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color.opacity(0.1))
            )
    }

    // MARK: - Computed Properties

    @State private var isDragging = false

    private var thumbSize: CGFloat {
        24
    }

    private func trackWidth(geometry: GeometryProxy) -> CGFloat {
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return geometry.size.width * CGFloat(normalizedValue)
    }

    private func thumbPosition(geometry: GeometryProxy) -> CGFloat {
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return geometry.size.width * CGFloat(normalizedValue)
    }

    private func normalizedValue(for location: CGFloat, in geometry: GeometryProxy) -> Double {
        let clampedLocation = max(0, min(location, geometry.size.width))
        let normalized = Double(clampedLocation / geometry.size.width)
        let rawValue = range.lowerBound + normalized * (range.upperBound - range.lowerBound)
        return snapToStep(rawValue)
    }

    private func snapToStep(_ rawValue: Double) -> Double {
        let snapped = round(rawValue / step) * step
        return min(max(snapped, range.lowerBound), range.upperBound)
    }

    // MARK: - Drag Gesture

    private func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDragging = true
                let newValue = normalizedValue(for: value.location.x, in: geometry)
                self.value = newValue
                onValueChanged?(newValue)
            }
            .onEnded { _ in
                isDragging = false
                let snappedValue = snapToStep(value)
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    self.value = snappedValue
                    onValueChanged?(snappedValue)
                }
            }
    }
}
