//
//  WeekProgressView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

// MARK: - Equal Width Segmented Progress View

/// 等幅セグメントプログレスビュー
public struct EqualWidthSegmentedProgressView: View {
    private let progressValues: [Double]
    private let colors: [Color]
    private let labels: [String?]
    private let style: SegmentedProgressView.SegmentedProgressStyle
    private let showLabels: Bool

    public init(
        progressValues: [Double],
        colors: [Color],
        labels: [String?]? = nil,
        style: SegmentedProgressView.SegmentedProgressStyle = .standard,
        showLabels: Bool = true
    ) {
        self.progressValues = progressValues
        self.colors = colors
        self.labels = labels ?? progressValues.map { _ in nil }
        self.style = style
        self.showLabels = showLabels
    }

    public var body: some View {
        SegmentedProgressView(
            segments: zip(progressValues, zip(colors, labels)).map { value, pair in
                SegmentedProgressView.Segment(value: value, color: pair.0, label: pair.1)
            },
            style: style,
            showLabels: showLabels
        )
    }
}

// MARK: - Week Progress View

/// 曜日別セグメントプログレスビュー
public struct WeekProgressView: View {
    private let weekData: [Double]
    private let style: SegmentedProgressView.SegmentedProgressStyle

    private let weekDays = ["月", "火", "水", "木", "金", "土", "日"]
    private let weekColors: [Color] = [
        .blue, .green, .orange, .purple, .pink, .red, .cyan
    ]

    public init(
        weekData: [Double],
        style: SegmentedProgressView.SegmentedProgressStyle = .standard
    ) {
        self.weekData = weekData
        self.style = style
    }

    public var body: some View {
        VStack(spacing: 12) {
            Text("週間進捗")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)

            SegmentedProgressView(
                segments: zip(weekData, zip(weekColors, weekDays)).map { value, pair in
                    SegmentedProgressView.Segment(
                        value: value,
                        color: pair.0,
                        label: pair.1
                    )
                },
                style: style,
                showLabels: true
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .drawingGroup()
    }
}
