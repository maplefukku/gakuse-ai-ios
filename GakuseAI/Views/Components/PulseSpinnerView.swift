//
//  PulseSpinnerView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

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
