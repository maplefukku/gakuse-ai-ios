//
//  BarSpinnerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

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
