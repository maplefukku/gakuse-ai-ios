//
//  SpinnerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// MARK: - Spinner View

/// スピナーローディングコンポーネント
///
/// - 複数のスタイル: standard, minimal, colorful
/// - カスタマイズ可能な色、サイズ、アニメーション速度
public struct SpinnerView: View {
    private let style: SpinnerStyle
    private let color: Color
    private let size: CGFloat
    private let lineWidth: CGFloat
    private let animationDuration: Double
    
    @State private var isAnimating: Bool = false
    
    public enum SpinnerStyle {
        case standard
        case minimal
        case colorful
    }
    
    /// スピナービューを初期化
    /// - Parameters:
    ///   - style: スピナーのスタイル（デフォルト: standard）
    ///   - color: スピナーの色（デフォルト: アクセントカラー）
    ///   - size: スピナーのサイズ（デフォルト: 40）
    ///   - lineWidth: 線の太さ（デフォルト: 3）
    ///   - animationDuration: アニメーション時間（秒）
    public init(
        style: SpinnerStyle = .standard,
        color: Color = .accentColor,
        size: CGFloat = 40,
        lineWidth: CGFloat = 3,
        animationDuration: Double = 1.0
    ) {
        self.style = style
        self.color = color
        self.size = size
        self.lineWidth = lineWidth
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        spinnerContent
            .onAppear {
                isAnimating = true
            }
            .drawingGroup()
    }
    
    @ViewBuilder
    private var spinnerContent: some View {
        switch style {
        case .standard:
            standardSpinner
        case .minimal:
            minimalSpinner
        case .colorful:
            colorfulSpinner
        }
    }
    
    // MARK: - Standard Spinner
    
    @ViewBuilder
    private var standardSpinner: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: animationDuration)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .frame(width: size, height: size)
    }
    
    // MARK: - Minimal Spinner
    
    @ViewBuilder
    private var minimalSpinner: some View {
        Circle()
            .trim(from: 0.5, to: 1)
            .stroke(
                color,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                .linear(duration: animationDuration)
                .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .frame(width: size, height: size)
    }
    
    // MARK: - Colorful Spinner
    
    @ViewBuilder
    private var colorfulSpinner: some View {
        ZStack {
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            color,
                            color.opacity(0.8),
                            color.opacity(0.6),
                            color.opacity(0.4),
                            color.opacity(0.2)
                        ],
                        center: .center
                    ),
                    lineWidth: lineWidth
                )
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: animationDuration)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Dots Spinner

/// ドットスピナー
public struct DotsSpinnerView: View {
    private let count: Int
    private let color: Color
    private let size: CGFloat
    private let animationDelay: Double
    
    @State private var isAnimating: Bool = false
    
    public init(
        count: Int = 3,
        color: Color = .accentColor,
        size: CGFloat = 10,
        animationDelay: Double = 0.15
    ) {
        self.count = count
        self.color = color
        self.size = size
        self.animationDelay = animationDelay
    }
    
    public var body: some View {
        HStack(spacing: size / 2) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * animationDelay),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
        .drawingGroup()
    }
}

// MARK: - Bar Spinner

/// バースピナー
public struct BarSpinnerView: View {
    private let count: Int
    private let color: Color
    private let barWidth: CGFloat
    private let barHeight: CGFloat
    private let animationDelay: Double
    
    @State private var isAnimating: Bool = false
    
    public init(
        count: Int = 4,
        color: Color = .accentColor,
        barWidth: CGFloat = 4,
        barHeight: CGFloat = 20,
        animationDelay: Double = 0.1
    ) {
        self.count = count
        self.color = color
        self.barWidth = barWidth
        self.barHeight = barHeight
        self.animationDelay = animationDelay
    }
    
    public var body: some View {
        HStack(spacing: barWidth) {
            ForEach(0..<count, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(color)
                    .frame(width: barWidth, height: isAnimating ? barHeight : barHeight * 0.4)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * animationDelay),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
        .drawingGroup()
    }
}

// MARK: - Pulse Spinner

/// パルススピナー
public struct PulseSpinnerView: View {
    private let color: Color
    private let size: CGFloat
    
    @State private var scale: CGFloat = 1.0
    
    public init(color: Color = .accentColor, size: CGFloat = 50) {
        self.color = color
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .opacity(0.3)
                .scaleEffect(scale)
                .animation(
                    .easeOut(duration: 1.0)
                    .repeatForever(autoreverses: false),
                    value: scale
                )
            
            Circle()
                .fill(color)
                .frame(width: size * 0.6, height: size * 0.6)
                .opacity(0.6)
        }
        .onAppear {
            withAnimation {
                scale = 1.5
            }
        }
        .drawingGroup()
    }
}


