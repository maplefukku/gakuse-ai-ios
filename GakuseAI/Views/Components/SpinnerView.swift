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
