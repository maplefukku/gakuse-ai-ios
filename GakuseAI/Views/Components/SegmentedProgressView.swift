//
//  SegmentedProgressView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// MARK: - Segmented Progress View

/// セグメントプログレスビュー
///
/// - カスタマイズ可能なスタイル
/// - 複数のセグメント対応
/// - アニメーション付きプログレス表示
public struct SegmentedProgressView: View {
    private let segments: [Segment]
    private let style: SegmentedProgressStyle
    private let showLabels: Bool
    private let animationDuration: Double
    
    public enum SegmentedProgressStyle {
        case standard
        case minimal
        case pill
        case rounded
    }
    
    public struct Segment: Identifiable {
        public let id = UUID()
        public let value: Double
        public let color: Color
        public let label: String?
        
        public init(
            value: Double,
            color: Color,
            label: String? = nil
        ) {
            self.value = value
            self.color = color
            self.label = label
        }
    }
    
    /// セグメントプログレスビューを初期化
    /// - Parameters:
    ///   - segments: セグメントの配列
    ///   - style: プログレスバーのスタイル（デフォルト: standard）
    ///   - showLabels: ラベル表示（デフォルト: true）
    ///   - animationDuration: アニメーション時間（秒）（デフォルト: 0.5）
    public init(
        segments: [Segment],
        style: SegmentedProgressStyle = .standard,
        showLabels: Bool = true,
        animationDuration: Double = 0.5
    ) {
        self.segments = segments
        self.style = style
        self.showLabels = showLabels
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            progressBar
            
            if showLabels {
                labelsView
            }
        }
        .drawingGroup()
    }
    
    // MARK: - Progress Bar
    
    @ViewBuilder
    private var progressBar: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let totalValue = segments.reduce(0) { $0 + $1.value }
            
            HStack(spacing: 0) {
                ForEach(segments.indices, id: \.self) { index in
                    let segment = segments[index]
                    let segmentWidth = totalValue > 0 ? (segment.value / totalValue) * totalWidth : 0
                    
                    Rectangle()
                        .fill(segment.color)
                        .frame(width: segmentWidth)
                        .animation(.easeInOut(duration: animationDuration), value: segmentWidth)
                }
            }
            .frame(height: 12)
        }
        .frame(height: 12)
    }
    
    @ViewBuilder
    private var labelsView: some View {
        HStack(alignment: .center, spacing: 16) {
            ForEach(segments) { segment in
                if let label = segment.label {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(segment.color)
                            .frame(width: 8, height: 8)
                        
                        Text(label)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Text("\(Int(segments.reduce(0) { $0 + $1.value }))%")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Segmented Progress View Extension

extension SegmentedProgressView {
    @ViewBuilder
    func progressBarStyle(_ style: SegmentedProgressStyle) -> some View {
        switch style {
        case .standard:
            self
                .cornerRadius(2)
        case .minimal:
            self
        case .pill:
            self
                .cornerRadius(6)
        case .rounded:
            self
                .cornerRadius(10)
        }
    }
}

// MARK: - Segmented Progress View (Equal Width)

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

// MARK: - Segmented Progress View (Week)

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

// MARK: - Segmented Progress View (Category)

/// カテゴリ別セグメントプログレスビュー
public struct CategoryProgressView: View {
    private let categories: [Category]
    private let style: SegmentedProgressView.SegmentedProgressStyle
    
    public struct Category: Identifiable {
        public let id = UUID()
        public let name: String
        public let value: Double
        public let color: Color
    }
    
    public init(
        categories: [Category],
        style: SegmentedProgressView.SegmentedProgressStyle = .standard
    ) {
        self.categories = categories
        self.style = style
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("カテゴリ別進捗")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            SegmentedProgressView(
                segments: categories.map { category in
                    SegmentedProgressView.Segment(
                        value: category.value,
                        color: category.color,
                        label: category.name
                    )
                },
                style: style,
                showLabels: true
            )
            
            categoryList
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .drawingGroup()
    }
    
    @ViewBuilder
    private var categoryList: some View {
        VStack(spacing: 12) {
            ForEach(categories) { category in
                HStack {
                    Circle()
                        .fill(category.color)
                        .frame(width: 12, height: 12)
                    
                    Text(category.name)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(category.value))%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

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


