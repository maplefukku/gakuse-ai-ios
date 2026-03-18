//
//  SimpleSegmentedProgressView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

// MARK: - Simple Segmented Progress View

/// シンプルなセグメントプログレスビュー
public struct SimpleSegmentedProgressView: View {
    private let values: [Double]
    private let colors: [Color]

    public init(
        values: [Double],
        colors: [Color]
    ) {
        self.values = values
        self.colors = colors
    }

    public var body: some View {
        SegmentedProgressView(
            segments: zip(values, colors).map { value, color in
                SegmentedProgressView.Segment(value: value, color: color)
            },
            style: .minimal,
            showLabels: false
        )
    }
}
