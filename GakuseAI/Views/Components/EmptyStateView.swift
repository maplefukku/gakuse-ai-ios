//
//  EmptyStateView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//  Copyright © 2026 GakuseAI. All rights reserved.
//

import SwiftUI

/// 空の状態を表示する汎用コンポーネント
///
/// - 複数のスタイル: standard, minimal, illustrated
/// - カスタマイズ可能なアイコン、タイトル、メッセージ、アクションボタン
struct EmptyStateView: View {
    // MARK: - Styles
    
    enum Style {
        case standard
        case minimal
        case illustrated
    }
    
    // MARK: - Properties
    
    private let icon: String?
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let style: Style
    
    // MARK: - Initialization
    
    /// 基本的なEmptyStateViewを初期化
    init(
        icon: String? = nil,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        style: Style = .standard
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.style = style
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
            .drawingGroup()
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        switch style {
        case .standard:
            standardView
        case .minimal:
            minimalView
        case .illustrated:
            illustratedView
        }
    }
    
    // MARK: - Style Views
    
    private var standardView: some View {
        VStack(spacing: 20) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            if let message = message {
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
                .buttonStyle(EmptyStateScaleButtonStyle(scale: 0.95))
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 40)
    }
    
    private var minimalView: some View {
        VStack(spacing: 16) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let message = message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 32)
    }
    
    private var illustratedView: some View {
        VStack(spacing: 24) {
            if let icon = icon {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: icon)
                        .font(.system(size: 56))
                        .foregroundColor(.accentColor)
                }
                .padding(.top, 60)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                if let message = message {
                    Text(message)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack {
                        Text(actionTitle)
                            .font(.body)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.body)
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(EmptyStateScaleButtonStyle(scale: 0.95))
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 60)
    }
}
