//
//  ModalView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-09.
//

import SwiftUI

// MARK: - ModalView

/// モーダルビューを表示するためのコンポーネント
public struct ModalView<Content: View>: View {
    @Binding private var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var showOverlay: Bool = false
    
    private let content: Content
    private let style: ModalStyle
    private let presentationMode: PresentationMode
    private let dismissOnBackgroundTap: Bool
    private let dismissOnDrag: Bool
    private let animationDuration: Double
    
    public enum ModalStyle {
        case sheet
        case fullScreen
        case bottomSheet
        case center
    }
    
    public enum PresentationMode {
        case standard
        case scale
        case slideIn(from: Edge)
    }
    
    /// モーダルビューを初期化
    /// - Parameters:
    ///   - isPresented: モーダルを表示するかどうか
    ///   - style: モーダルのスタイル（デフォルト: sheet）
    ///   - presentationMode: プレゼンテーションモード（デフォルト: standard）
    ///   - dismissOnBackgroundTap: 背景タップで閉じるか（デフォルト: true）
    ///   - dismissOnDrag: ドラッグで閉じるか（デフォルト: true）
    ///   - animationDuration: アニメーションの長さ（秒）
    ///   - content: モーダルのコンテンツ
    public init(
        isPresented: Binding<Bool>,
        style: ModalStyle = .sheet,
        presentationMode: PresentationMode = .standard,
        dismissOnBackgroundTap: Bool = true,
        dismissOnDrag: Bool = true,
        animationDuration: Double = 0.3,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.style = style
        self.presentationMode = presentationMode
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.dismissOnDrag = dismissOnDrag
        self.animationDuration = animationDuration
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            if isPresented {
                // オーバーレイ背景
                overlay
                    .transition(.opacity)
                
                // モーダルコンテンツ
                modalContainer
                    .transition(modalTransition)
            }
        }
        .animation(.easeInOut(duration: animationDuration), value: isPresented)
    }
    
    @ViewBuilder
    private var overlay: some View {
        if showOverlay {
            Color.black
                .opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if dismissOnBackgroundTap {
                        dismiss()
                    }
                }
                .drawingGroup()
        }
    }
    
    @ViewBuilder
    private var modalContainer: some View {
        GeometryReader { geometry in
            ZStack {
                switch style {
                case .sheet:
                    sheetModal(in: geometry)
                case .fullScreen:
                    fullScreenModal
                case .bottomSheet:
                    bottomSheetModal(in: geometry)
                case .center:
                    centerModal(in: geometry)
                }
            }
            .gesture(
                dismissOnDrag ? dragGesture : nil
            )
            .drawingGroup()
        }
    }
    
    @ViewBuilder
    private func sheetModal(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // ドラッグインジケーター
            DragIndicator()
            
            content
                .frame(maxWidth: .infinity)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: geometry.size.height * modalHeightRatio)
        .background(Color(.systemBackground))
        .cornerRadius(cornerRadius)
        .shadow(radius: 20)
        .offset(y: dragOffset)
        .drawingGroup()
    }
    
    @ViewBuilder
    private var fullScreenModal: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .drawingGroup()
    }
    
    @ViewBuilder
    private func bottomSheetModal(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // ドラッグインジケーター
            DragIndicator()
            
            content
                .frame(maxWidth: .infinity)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: geometry.size.height * modalHeightRatio)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(.systemBackground))
        )
        .shadow(radius: 20)
        .offset(y: dragOffset)
        .drawingGroup()
    }
    
    @ViewBuilder
    private func centerModal(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            // 閉じるボタン
            HStack {
                Spacer()
                Button(action: dismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            content
                .padding(.horizontal)
        }
        .frame(maxWidth: geometry.size.width * modalWidthRatio)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(.systemBackground))
        )
        .shadow(radius: 20)
        .drawingGroup()
    }
    
    private var modalHeightRatio: CGFloat {
        switch style {
        case .sheet:
            return 0.7
        case .fullScreen:
            return 1.0
        case .bottomSheet:
            return 0.5
        case .center:
            return 0.0
        }
    }
    
    private var modalWidthRatio: CGFloat {
        0.9
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case .sheet, .bottomSheet:
            return 20
        case .fullScreen:
            return 0
        case .center:
            return 16
        }
    }
    
    private var modalTransition: AnyTransition {
        switch presentationMode {
        case .standard:
            return .opacity
        case .scale:
            return .scale(scale: 0.9).combined(with: .opacity)
        case .slideIn(let edge):
            return .move(edge: edge).combined(with: .opacity)
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if style != .fullScreen {
                    dragOffset = value.translation.height
                }
            }
            .onEnded { value in
                if style != .fullScreen {
                    if value.translation.height > 100 {
                        dismiss()
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = 0
                        }
                    }
                }
            }
    }
    
    private func dismiss() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            isPresented = false
            dragOffset = 0
        }
    }
}

// MARK: - DragIndicator

/// ドラッグインジケーター（ボトムシート用）
private struct DragIndicator: View {
    var body: some View {
        HStack {
            Spacer()
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - View Extension

extension View {
    /// モーダルを表示する修飾子
    public func modal<Content: View>(
        isPresented: Binding<Bool>,
        style: ModalView.ModalStyle = .sheet,
        presentationMode: ModalView.PresentationMode = .standard,
        dismissOnBackgroundTap: Bool = true,
        dismissOnDrag: Bool = true,
        animationDuration: Double = 0.3,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.background(
            ModalView(
                isPresented: isPresented,
                style: style,
                presentationMode: presentationMode,
                dismissOnBackgroundTap: dismissOnBackgroundTap,
                dismissOnDrag: dismissOnDrag,
                animationDuration: animationDuration,
                content: content
            )
        )
    }
}

// MARK: - Previews

#Preview("Sheet Style") {
    ModalViewExample()
}

#Preview("Bottom Sheet Style") {
    ModalViewExample(style: .bottomSheet)
}

#Preview("Full Screen Style") {
    ModalViewExample(style: .fullScreen)
}

#Preview("Center Style") {
    ModalViewExample(style: .center)
}

#Preview("Scale Animation") {
    ModalViewExample(style: .center, presentationMode: .scale)
}

#Preview("Slide In Animation") {
    ModalViewExample(style: .center, presentationMode: .slideIn(from: .bottom))
}

// MARK: - Preview Helper

private struct ModalViewExample: View {
    @State private var isPresented = false
    
    let style: ModalView.ModalStyle
    let presentationMode: ModalView.PresentationMode
    
    init(style: ModalView.ModalStyle = .sheet, presentationMode: PresentationMode = .standard) {
        self.style = style
        self.presentationMode = presentationMode
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Show Modal") {
                isPresented = true
            }
            .buttonStyle(.borderedProminent)
            
            Text("スタイル: \(String(describing: style))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .modal(
            isPresented: $isPresented,
            style: style,
            presentationMode: presentationMode
        ) {
            VStack(spacing: 20) {
                Text("モーダルタイトル")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("これはモーダルのコンテンツです。")
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    Button("キャンセル") {
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("確認") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}
