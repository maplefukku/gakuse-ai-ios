//
//  Toast.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-09.
//

import SwiftUI

// MARK: - Toast Message
struct ToastMessage: Identifiable, Equatable {
    let id: String = UUID().uuidString
    let text: String
    let type: ToastType
    let duration: TimeInterval
    var icon: String?
    var action: ToastAction?

    init(
        text: String,
        type: ToastType = .info,
        duration: TimeInterval = 3.0,
        icon: String? = nil,
        action: ToastAction? = nil
    ) {
        self.text = text
        self.type = type
        self.duration = duration
        self.icon = icon
        self.action = action
    }

    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toast Type
enum ToastType {
    case success
    case error
    case warning
    case info

    var icon: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success:
            return .green
        case .error:
            return .red
        case .warning:
            return .orange
        case .info:
            return .blue
        }
    }

    var backgroundColor: Color {
        switch self {
        case .success:
            return Color(.systemGreen).opacity(0.1)
        case .error:
            return Color(.systemRed).opacity(0.1)
        case .warning:
            return Color(.systemOrange).opacity(0.1)
        case .info:
            return Color(.systemBlue).opacity(0.1)
        }
    }
}

// MARK: - Toast Action
struct ToastAction {
    let title: String
    let action: () -> Void
}

// MARK: - Toast View
struct Toast: View {
    let message: ToastMessage
    var style: ToastStyle = .standard
    var onDismiss: (() -> Void)? = nil
    var onAction: (() -> Void)? = nil

    @State private var isPressed: Bool = false
    @State private var offsetX: CGFloat = 0

    var body: some View {
        HStack(spacing: 12) {
            // アイコン
            Image(systemName: message.icon ?? message.type.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(message.type.color)
                .frame(width: 24, height: 24)

            // テキスト
            Text(message.text)
                .font(.system(size: style.fontSize, weight: .regular))
                .foregroundColor(.primary)
                .lineLimit(style.lineLimit)
                .multilineTextAlignment(.leading)

            Spacer()

            // アクションボタン
            if let action = message.action {
                Button(action: {
                    action.action()
                    onAction?()
                    onDismiss?()
                }) {
                    Text(action.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(message.type.color)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // 閉じるボタン
            if style.showDismissButton {
                Button(action: onDismiss ?? {}) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, style.padding)
        .padding(.vertical, style.padding * 0.75)
        .background(toastBackground)
        .cornerRadius(style.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(message.type.color.opacity(0.2), lineWidth: style.borderWidth)
        )
        .shadow(color: Color.black.opacity(style.shadowOpacity), radius: style.shadowRadius, x: 0, y: style.shadowYOffset)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .offset(x: offsetX)
        .onTapGesture {
            // スワイプして閉じる
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                offsetX = 300
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onDismiss?()
            }
        }
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
        .animation(Animation.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        .accessibilityLabel(message.text)
        .accessibilityAddTraits([.isStaticText])
    }

    @ViewBuilder
    private var toastBackground: some View {
        if style.isTransparent {
            message.type.backgroundColor
        } else {
            Color(.systemBackground)
        }
    }
}

// MARK: - Toast Container
struct ToastContainer: View {
    @Binding var messages: [ToastMessage]
    var style: ToastStyle = .standard
    var maxToasts: Int = 3

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(messages.prefix(maxToasts).enumerated()), id: \.element.id) { index, message in
                Toast(
                    message: message,
                    style: style,
                    onDismiss: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            messages.removeAll { $0.id == message.id }
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .drawingGroup()
    }
}


