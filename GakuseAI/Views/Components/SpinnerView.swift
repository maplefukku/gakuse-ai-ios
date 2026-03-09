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

// MARK: - Previews

#Preview("Standard Style") {
    VStack(spacing: 20) {
        Text("Standard Style")
            .font(.headline)
        
        SpinnerView()
        
        SpinnerView(color: .blue)
        
        SpinnerView(color: .green, size: 60)
        
        SpinnerView(color: .red, size: 80, lineWidth: 4)
    }
    .padding()
}

#Preview("Minimal Style") {
    VStack(spacing: 20) {
        Text("Minimal Style")
            .font(.headline)
        
        SpinnerView(style: .minimal)
        
        SpinnerView(style: .minimal, color: .orange)
        
        SpinnerView(style: .minimal, size: 50, lineWidth: 2)
    }
    .padding()
}

#Preview("Colorful Style") {
    VStack(spacing: 20) {
        Text("Colorful Style")
            .font(.headline)
        
        SpinnerView(style: .colorful)
        
        SpinnerView(style: .colorful, color: .purple)
        
        SpinnerView(style: .colorful, color: .pink, size: 60)
    }
    .padding()
}

#Preview("Dots Spinner") {
    VStack(spacing: 20) {
        Text("Dots Spinner")
            .font(.headline)
        
        DotsSpinnerView()
        
        DotsSpinnerView(count: 4)
        
        DotsSpinnerView(color: .blue, size: 15)
        
        DotsSpinnerView(color: .green, size: 8)
    }
    .padding()
}

#Preview("Bar Spinner") {
    VStack(spacing: 20) {
        Text("Bar Spinner")
            .font(.headline)
        
        BarSpinnerView()
        
        BarSpinnerView(count: 5)
        
        BarSpinnerView(color: .orange)
        
        BarSpinnerView(color: .purple, barWidth: 6, barHeight: 30)
    }
    .padding()
}

#Preview("Pulse Spinner") {
    VStack(spacing: 20) {
        Text("Pulse Spinner")
            .font(.headline)
        
        PulseSpinnerView()
        
        PulseSpinnerView(color: .blue)
        
        PulseSpinnerView(color: .green, size: 60)
        
        PulseSpinnerView(color: .red, size: 80)
    }
    .padding()
}

#Preview("Spinner Sizes") {
    VStack(spacing: 20) {
        Text("Spinner Sizes")
            .font(.headline)
        
        HStack(spacing: 20) {
            SpinnerView(size: 24)
            Text("Small")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        
        HStack(spacing: 20) {
            SpinnerView(size: 40)
            Text("Medium")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        
        HStack(spacing: 20) {
            SpinnerView(size: 60)
            Text("Large")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        
        HStack(spacing: 20) {
            SpinnerView(size: 80)
            Text("Extra Large")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    .padding()
}

#Preview("Spinner Gallery") {
    ScrollView {
        VStack(spacing: 30) {
            Text("Standard Spinner")
                .font(.headline)
            
            SpinnerView()
            
            DividerView()
            
            Text("Minimal Spinner")
                .font(.headline)
            
            SpinnerView(style: .minimal)
            
            DividerView()
            
            Text("Colorful Spinner")
                .font(.headline)
            
            SpinnerView(style: .colorful)
            
            DividerView()
            
            Text("Dots Spinner")
                .font(.headline)
            
            DotsSpinnerView()
            
            DividerView()
            
            Text("Bar Spinner")
                .font(.headline)
            
            BarSpinnerView()
            
            DividerView()
            
            Text("Pulse Spinner")
                .font(.headline)
            
            PulseSpinnerView()
        }
        .padding()
    }
}
