//
//  SkeletonView.swift
//  GakuseAI
//
//  Created by OpenGoat on 2026-03-10.
//

import SwiftUI

// MARK: - SkeletonView
/// コンテンツのロード中に表示されるスケルトンローディングビュー
public struct SkeletonView: View {
    // MARK: - Properties
    private let width: CGFloat?
    private let height: CGFloat
    private let cornerRadius: CGFloat
    private let style: SkeletonStyle
    @State private var isAnimating = true

    // MARK: - Style Definition
    public enum SkeletonStyle {
        case standard
        case shimmer
        case pulse
        case gradient

        var animationDuration: Double {
            switch self {
            case .standard, .shimmer: return 1.5
            case .pulse: return 1.0
            case .gradient: return 2.0
            }
        }
    }

    // MARK: - Initializer
    public init(
        width: CGFloat? = nil,
        height: CGFloat,
        cornerRadius: CGFloat = 8,
        style: SkeletonStyle = .shimmer
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.style = style
    }

    // MARK: - Body
    public var body: some View {
        Group {
            switch style {
            case .standard:
                standardSkeleton
            case .shimmer:
                shimmerSkeleton
            case .pulse:
                pulseSkeleton
            case .gradient:
                gradientSkeleton
            }
        }
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }

    @ViewBuilder
    private var standardSkeleton: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.secondary.opacity(0.2))
            .frame(width: width, height: height)
            .accessibilityElement()
            .accessibilityLabel("ロード中")
            .accessibility(hidden: true)
    }

    @ViewBuilder
    private var shimmerSkeleton: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.secondary.opacity(0.2))
            .frame(width: width, height: height)
            .overlay {
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.5)
                        .offset(x: isAnimating ? geometry.size.width * 1.5 : -geometry.size.width * 0.5)
                        .animation(
                            Animation.linear(duration: style.animationDuration)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
                .clipped()
            }
            .accessibilityElement()
            .accessibilityLabel("ロード中")
            .accessibility(hidden: true)
    }

    @ViewBuilder
    private var pulseSkeleton: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.secondary.opacity(0.2))
            .frame(width: width, height: height)
            .opacity(isAnimating ? 0.5 : 1.0)
            .animation(
                Animation.easeInOut(duration: style.animationDuration)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .accessibilityElement()
            .accessibilityLabel("ロード中")
            .accessibility(hidden: true)
    }

    @ViewBuilder
    private var gradientSkeleton: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.secondary.opacity(0.1),
                        Color.secondary.opacity(0.3),
                        Color.secondary.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: width, height: height)
            .overlay {
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                        .rotationEffect(.degrees(45))
                        .animation(
                            Animation.linear(duration: style.animationDuration)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
                .clipped()
            }
            .accessibilityElement()
            .accessibilityLabel("ロード中")
            .accessibility(hidden: true)
    }
}
