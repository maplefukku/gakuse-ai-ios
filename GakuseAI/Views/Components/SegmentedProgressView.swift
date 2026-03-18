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


