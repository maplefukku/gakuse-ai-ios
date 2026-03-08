import UIKit

/// Haptic Feedbackユーティリティ
/// SOUL.mdのビジョン「学習ログを資産化」を実現 - UX向上のための触覚フィードバック
struct HapticFeedback {
    
    /// 軽い触覚フィードバック
    @MainActor
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// 中程度の触覚フィードバック
    @MainActor
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// 強い触覚フィードバック
    @MainActor
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// 選択時の触覚フィードバック
    @MainActor
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    /// 通知時の触覚フィードバック（成功）
    @MainActor
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    /// 通知時の触覚フィードバック（警告）
    @MainActor
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// 通知時の触覚フィードバック（エラー）
    @MainActor
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
