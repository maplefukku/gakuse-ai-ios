//
//  DotsSpinnerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

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
