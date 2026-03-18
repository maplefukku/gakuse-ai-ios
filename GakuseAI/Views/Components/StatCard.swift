//
//  StatCard.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// 統計カードビュー
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let delay: Double

    @State private var isVisible = false
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay), value: isVisible)

            Text(value)
                .font(.title.bold())
                .opacity(isVisible ? 1.0 : 0.0)
                .offset(y: isVisible ? 0 : 10)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay + 0.1), value: isVisible)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .scaleEffect(isPressed ? 0.95 : (isVisible ? 1.0 : 0.9))
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay), value: isVisible)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}
