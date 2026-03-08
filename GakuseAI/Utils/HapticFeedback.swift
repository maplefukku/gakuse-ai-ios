import UIKit
import SwiftUI

/// Haptic Feedback（触覚フィードバック）の拡張
enum HapticFeedback {
    /// 軽いフィードバック（選択、タップなど）
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// 中程度のフィードバック（ボタンクリック、操作完了など）
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// 強いフィードバック（重要な操作、エラーなど）
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// 成功フィードバック（保存完了、成功操作など）
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// 警告フィードバック（確認が必要な操作など）
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// エラーフィードバック（失敗操作など）
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

/// ViewModifierによるHaptic Feedbackの追加
struct HapticTapModifier: ViewModifier {
    let feedback: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        feedback()
                    }
            )
    }
}

extension View {
    /// タップ時にHaptic Feedbackを実行
    func hapticTap(_ feedback: @escaping () -> Void = { HapticFeedback.light() }) -> some View {
        self.modifier(HapticTapModifier(feedback: feedback))
    }
    
    /// 軽いHaptic Feedbackをタップ時に実行
    func hapticLightTap() -> some View {
        hapticTap { HapticFeedback.light() }
    }
    
    /// 中程度のHaptic Feedbackをタップ時に実行
    func hapticMediumTap() -> some View {
        hapticTap { HapticFeedback.medium() }
    }
    
    /// 強いHaptic Feedbackをタップ時に実行
    func hapticHeavyTap() -> some View {
        hapticTap { HapticFeedback.heavy() }
    }
}
