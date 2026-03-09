//
//  OnboardingView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

// MARK: - Onboarding View

/// オンボーディングビュー
///
/// - スワイプ可能なページ
/// - カスタマイズ可能なページ、色、ボタン
/// - アニメーション付き
public struct OnboardingView: View {
    private let pages: [OnboardingPage]
    private let showSkipButton: Bool
    private let skipButtonTitle: String
    private let nextButtonTitle: String
    private let doneButtonTitle: String
    private let onSkip: (() -> Void)?
    private let onDone: (() -> Void)?
    
    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = 0
    
    public struct OnboardingPage: Identifiable {
        public let id = UUID()
        public let title: String
        public let subtitle: String
        public let image: String
        public let backgroundColor: Color?
        
        public init(
            title: String,
            subtitle: String,
            image: String,
            backgroundColor: Color? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.backgroundColor = backgroundColor
        }
    }
    
    /// オンボーディングビューを初期化
    /// - Parameters:
    ///   - pages: オンボーディングページの配列
    ///   - showSkipButton: スキップボタンを表示するか（デフォルト: true）
    ///   - skipButtonTitle: スキップボタンのタイトル（デフォルト: "スキップ"）
    ///   - nextButtonTitle: 次へボタンのタイトル（デフォルト: "次へ"）
    ///   - doneButtonTitle: 完了ボタンのタイトル（デフォルト: "始める"）
    ///   - onSkip: スキップ時のアクション
    ///   - onDone: 完了時のアクション
    public init(
        pages: [OnboardingPage],
        showSkipButton: Bool = true,
        skipButtonTitle: String = "スキップ",
        nextButtonTitle: String = "次へ",
        doneButtonTitle: String = "始める",
        onSkip: (() -> Void)? = nil,
        onDone: (() -> Void)? = nil
    ) {
        self.pages = pages
        self.showSkipButton = showSkipButton
        self.skipButtonTitle = skipButtonTitle
        self.nextButtonTitle = nextButtonTitle
        self.doneButtonTitle = doneButtonTitle
        self.onSkip = onSkip
        self.onDone = onDone
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                if let bgColor = currentPage < pages.count ? pages[currentPage].backgroundColor : nil {
                    bgColor
                        .ignoresSafeArea()
                } else {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 0) {
                    // Top Bar
                    if showSkipButton {
                        HStack {
                            Spacer()
                            skipButton
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                    
                    // Content
                    pageContent
                        .frame(height: geometry.size.height * 0.6)
                    
                    Spacer()
                    
                    // Bottom Controls
                    bottomControls
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
        }
        .drawingGroup()
    }
    
    // MARK: - Page Content
    
    @ViewBuilder
    private var pageContent: some View {
        if currentPage < pages.count {
            let page = pages[currentPage]
            
            VStack(spacing: 32) {
                // Image
                Image(systemName: page.image)
                    .font(.system(size: 120, weight: .light))
                    .foregroundColor(.primary)
                    .scaleEffect(1.0 + CGFloat(currentPage) * 0.1)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentPage)
                
                // Title
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
                
                // Subtitle
                Text(page.subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .transition(.opacity)
            }
            .id(page.id)
        }
    }
    
    // MARK: - Skip Button
    
    @ViewBuilder
    private var skipButton: some View {
        Button(action: {
            onSkip?()
        }) {
            Text(skipButtonTitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Bottom Controls
    
    @ViewBuilder
    private var bottomControls: some View {
        VStack(spacing: 24) {
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.primary : Color.gray.opacity(0.3))
                        .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                }
            }
            
            // Action Button
            actionButton
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        Button(action: {
            if currentPage < pages.count - 1 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentPage += 1
                }
            } else {
                onDone?()
            }
        }) {
            HStack {
                Spacer()
                Text(currentPage < pages.count - 1 ? nextButtonTitle : doneButtonTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 16)
            .background(Color.primary)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Compact Onboarding View

/// コンパクトなオンボーディングビュー
public struct CompactOnboardingView: View {
    private let pages: [CompactPage]
    private let onDone: (() -> Void)?
    
    @State private var currentPage: Int = 0
    
    public struct CompactPage: Identifiable {
        public let id = UUID()
        public let title: String
        public let subtitle: String
        public let icon: String
        
        public init(
            title: String,
            subtitle: String,
            icon: String
        ) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
        }
    }
    
    public init(
        pages: [CompactPage],
        onDone: (() -> Void)? = nil
    ) {
        self.pages = pages
        self.onDone = onDone
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Page Content
            VStack(spacing: 16) {
                if currentPage < pages.count {
                    let page = pages[currentPage]
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(.accentColor)
                    
                    Text(page.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(page.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .frame(maxHeight: .infinity)
            .drawingGroup()
            
            // Bottom Controls
            VStack(spacing: 16) {
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                    }
                }
                
                // Action Button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    } else {
                        onDone?()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(currentPage < pages.count - 1 ? "次へ" : "完了")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        .drawingGroup()
    }
}

// MARK: - Onboarding Page Indicator

/// オンボーディングページインジケーター
public struct OnboardingPageIndicator: View {
    private let currentPage: Int
    private let totalPages: Int
    private let activeColor: Color
    private let inactiveColor: Color
    
    public init(
        currentPage: Int,
        totalPages: Int,
        activeColor: Color = .primary,
        inactiveColor: Color = Color.gray.opacity(0.3)
    ) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? activeColor : inactiveColor)
                    .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
        .drawingGroup()
    }
}

// MARK: - Previews

#Preview("Onboarding") {
    OnboardingView(
        pages: [
            OnboardingPage(
                title: "学習を記録",
                subtitle: "毎日の学習を簡単に記録できるアプリです",
                image: "book.fill",
                backgroundColor: .blue.opacity(0.1)
            ),
            OnboardingPage(
                title: "進捗を可視化",
                subtitle: "学習の進捗をグラフで確認できます",
                image: "chart.line.uptrend.xyaxis",
                backgroundColor: .green.opacity(0.1)
            ),
            OnboardingPage(
                title: "AIと壁打ち",
                subtitle: "AIと対話して学習の理解を深めよう",
                image: "brain.head.profile",
                backgroundColor: .purple.opacity(0.1)
            )
        ],
        onSkip: {
            print("Skipped")
        },
        onDone: {
            print("Done")
        }
    )
}

#Preview("Compact Onboarding") {
    CompactOnboardingView(
        pages: [
            CompactPage(
                title: "ステップ1",
                subtitle: "最初のステップ",
                icon: "1.circle.fill"
            ),
            CompactPage(
                title: "ステップ2",
                subtitle: "2番目のステップ",
                icon: "2.circle.fill"
            ),
            CompactPage(
                title: "ステップ3",
                subtitle: "最後のステップ",
                icon: "3.circle.fill"
            )
        ],
        onDone: {
            print("Done")
        }
    )
    .frame(maxWidth: 400)
}

#Preview("Page Indicator") {
    VStack(spacing: 20) {
        Text("Page Indicator")
            .font(.headline)
        
        OnboardingPageIndicator(currentPage: 0, totalPages: 3)
        OnboardingPageIndicator(currentPage: 1, totalPages: 3)
        OnboardingPageIndicator(currentPage: 2, totalPages: 3)
    }
    .padding()
}
