//
//  SegmentedProgressView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//  Copyright © 2026 GakuseAI. All rights reserved.
//

import SwiftUI

/// ステップ形式の進捗を表示する汎用コンポーネント
///
/// - 複数のスタイル: standard, minimal, compact
/// - カスタマイズ可能なステップ、色、サイズ
/// - アクティブ/完了/未完了の状態管理
struct SegmentedProgressView: View {
    // MARK: - Styles
    
    enum Style {
        case standard
        case minimal
        case compact
    }
    
    // MARK: - Step
    
    struct Step: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let subtitle: String?
        let icon: String?
        let isCompleted: Bool
        let isActive: Bool
        
        init(
            title: String,
            subtitle: String? = nil,
            icon: String? = nil,
            isCompleted: Bool = false,
            isActive: Bool = false
        ) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.isCompleted = isCompleted
            self.isActive = isActive
        }
        
        static func == (lhs: Step, rhs: Step) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    // MARK: - Properties
    
    private let steps: [Step]
    private let activeStepIndex: Int
    private let style: Style
    private let activeColor: Color
    private let completedColor: Color
    private let incompleteColor: Color
    
    // MARK: - Initialization
    
    /// 基本的なSegmentedProgressViewを初期化
    init(
        steps: [Step],
        activeStepIndex: Int,
        style: Style = .standard,
        activeColor: Color = .accentColor,
        completedColor: Color = .green,
        incompleteColor: Color = .gray.opacity(0.3)
    ) {
        self.steps = steps
        self.activeStepIndex = activeStepIndex
        self.style = style
        self.activeColor = activeColor
        self.completedColor = completedColor
        self.incompleteColor = incompleteColor
    }
    
    /// シンプルなタイトル配列を持つSegmentedProgressViewを初期化
    init(
        titles: [String],
        activeStepIndex: Int,
        style: Style = .standard
    ) {
        self.steps = titles.enumerated().map { index, title in
            Step(
                title: title,
                isCompleted: index < activeStepIndex,
                isActive: index == activeStepIndex
            )
        }
        self.activeStepIndex = activeStepIndex
        self.style = style
        self.activeColor = .accentColor
        self.completedColor = .green
        self.incompleteColor = .gray.opacity(0.3)
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .drawingGroup()
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        switch style {
        case .standard:
            standardProgressView
        case .minimal:
            minimalProgressView
        case .compact:
            compactProgressView
        }
    }
    
    // MARK: - Style Views
    
    private var standardProgressView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(stepColor(for: step))
                                .frame(width: 40, height: 40)
                            
                            if step.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            } else if step.isActive {
                                Image(systemName: step.icon ?? "circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(index + 1)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .overlay(
                            Circle()
                                .stroke(step.isActive ? activeColor : Color.clear, lineWidth: 2)
                        )
                        
                        VStack(spacing: 2) {
                            Text(step.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(stepTextColor(for: step))
                            
                            if let subtitle = step.subtitle {
                                Text(subtitle)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if index < steps.count - 1 {
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
    
    private var minimalProgressView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    Circle()
                        .fill(stepColor(for: step))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(step.isActive ? activeColor : Color.clear, lineWidth: 2)
                        )
                    
                    if index < steps.count - 1 {
                        Capsule()
                            .fill(lineColor(from: step, to: steps[index + 1]))
                            .frame(height: 4)
                    }
                }
            }
            
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    Text(step.title)
                        .font(.caption)
                        .foregroundColor(stepTextColor(for: step))
                        .frame(maxWidth: .infinity)
                    
                    if index < steps.count - 1 {
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    private var compactProgressView: some View {
        HStack(spacing: 4) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(stepColor(for: step))
                    .frame(height: 8)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Helper Methods
    
    private func stepColor(for step: Step) -> Color {
        if step.isCompleted {
            return completedColor
        } else if step.isActive {
            return activeColor
        } else {
            return incompleteColor
        }
    }
    
    private func stepTextColor(for step: Step) -> Color {
        if step.isCompleted || step.isActive {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private func lineColor(from: Step, to: Step) -> Color {
        if from.isCompleted && to.isCompleted {
            return completedColor
        } else if from.isCompleted {
            return activeColor
        } else {
            return incompleteColor
        }
    }
}

// MARK: - Convenience Initializers

extension SegmentedProgressView {
    /// アカウント作成フロー用のSegmentedProgressView
    static func signUpFlow(
        currentStep: Int
    ) -> SegmentedProgressView {
        let steps: [String] = ["メールアドレス", "パスワード", "プロフィール", "完了"]
        return SegmentedProgressView(
            titles: steps,
            activeStepIndex: currentStep,
            style: .standard
        )
    }
    
    /// 学習目標設定用のSegmentedProgressView
    static func learningGoalSetup(
        currentStep: Int
    ) -> SegmentedProgressView {
        let steps: [String] = ["目標設定", "カテゴリ", "週間スケジュール", "確認"]
        return SegmentedProgressView(
            titles: steps,
            activeStepIndex: currentStep,
            style: .minimal
        )
    }
    
    /// オンボーディング用のSegmentedProgressView
    static func onboarding(
        currentStep: Int
    ) -> SegmentedProgressView {
        let steps = [
            Step(
                title: "ようこそ",
                subtitle: "GakuseAIへ",
                icon: "hand.wave.fill",
                isCompleted: currentStep > 0,
                isActive: currentStep == 0
            ),
            Step(
                title: "学習ログ",
                subtitle: "記録する",
                icon: "book.fill",
                isCompleted: currentStep > 1,
                isActive: currentStep == 1
            ),
            Step(
                title: "ポートフォリオ",
                subtitle: "公開する",
                icon: "doc.text.fill",
                isCompleted: currentStep > 2,
                isActive: currentStep == 2
            ),
            Step(
                title: "完了",
                subtitle: "始めよう",
                icon: "checkmark.circle.fill",
                isCompleted: currentStep > 3,
                isActive: currentStep == 3
            )
        ]
        return SegmentedProgressView(
            steps: steps,
            activeStepIndex: currentStep,
            style: .standard
        )
    }
}

// MARK: - Preview

#Preview("Standard Style") {
    SegmentedProgressView(
        titles: ["ステップ1", "ステップ2", "ステップ3", "ステップ4"],
        activeStepIndex: 1,
        style: .standard
    )
}

#Preview("Minimal Style") {
    SegmentedProgressView(
        titles: ["開始", "進行中", "完了"],
        activeStepIndex: 1,
        style: .minimal
    )
}

#Preview("Compact Style") {
    SegmentedProgressView(
        titles: ["1", "2", "3", "4", "5"],
        activeStepIndex: 2,
        style: .compact
    )
}

#Preview("Custom Steps with Icons") {
    let steps = [
        SegmentedProgressView.Step(
            title: "メール",
            subtitle: "アドレス入力",
            icon: "envelope.fill",
            isCompleted: true,
            isActive: false
        ),
        SegmentedProgressView.Step(
            title: "パスワード",
            subtitle: "設定",
            icon: "lock.fill",
            isCompleted: false,
            isActive: true
        ),
        SegmentedProgressView.Step(
            title: "プロフィール",
            subtitle: "設定",
            icon: "person.fill",
            isCompleted: false,
            isActive: false
        ),
        SegmentedProgressView.Step(
            title: "完了",
            subtitle: "",
            icon: "checkmark.circle.fill",
            isCompleted: false,
            isActive: false
        )
    ]
    
    return SegmentedProgressView(
        steps: steps,
        activeStepIndex: 1,
        style: .standard
    )
}

#Preview("Sign Up Flow") {
    SegmentedProgressView.signUpFlow(currentStep: 1)
}

#Preview("Learning Goal Setup") {
    SegmentedProgressView.learningGoalSetup(currentStep: 2)
}

#Preview("Onboarding") {
    SegmentedProgressView.onboarding(currentStep: 1)
}

#Preview("Completed All Steps") {
    SegmentedProgressView(
        titles: ["完了", "完了", "完了"],
        activeStepIndex: 2,
        style: .standard
    )
}

#Preview("Dark Mode") {
    SegmentedProgressView(
        titles: ["ステップ1", "ステップ2", "ステップ3"],
        activeStepIndex: 1,
        style: .standard
    )
    .preferredColorScheme(.dark)
}
