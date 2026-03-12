import Foundation
@preconcurrency import UserNotifications
import SwiftUI

/// プッシュ通知サービス
/// SOUL.mdのビジョン「人は入力しない」を実現 - 自動通知で学習を促進
@MainActor
class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published var isNotificationEnabled = false
    @Published var notificationTime: DateComponents?

    private let center = UNUserNotificationCenter.current()
    private let notificationIdentifiers = [
        "daily_learning_reminder",
        "weekly_summary"
    ]

    private override init() {
        super.init()
        setupNotificationDelegate()
        Task {
            await checkNotificationPermission()
            await setupNotificationCategories()
        }
    }

    // MARK: - Setup

    private func setupNotificationDelegate() {
        center.delegate = self
    }

    @MainActor
    func checkNotificationPermission() async {
        let settings = await center.notificationSettings()
        isNotificationEnabled = settings.authorizationStatus == .authorized
    }

    // MARK: - Request Permission

    func requestNotificationPermission() async -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        do {
            let granted = try await center.requestAuthorization(options: options)
            self.isNotificationEnabled = granted
            return granted
        } catch {
            print("通知権限リクエストエラー: \(error)")
            return false
        }
    }

    // MARK: - Schedule Notifications

    /// 日次学習リマインダーをスケジュール
    /// - Parameter hour: 通知時間（0-23）
    func scheduleDailyReminder(at hour: Int) async {
        guard isNotificationEnabled else {
            print("通知が有効ではありません")
            return
        }

        // 既存の通知をキャンセル
        center.removePendingNotificationRequests(withIdentifiers: ["daily_learning_reminder"])

        let notificationTime = DateComponents(hour: hour, minute: 0)
        self.notificationTime = notificationTime

        // 通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = "学習の時間です！📚"
        content.body = "今日の学習ログを記録しましょう"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "LEARNING_REMINDER"

        // トリガーの作成（毎日同じ時間）
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: notificationTime,
            repeats: true
        )

        // 通知リクエストの作成
        let request = UNNotificationRequest(
            identifier: "daily_learning_reminder",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            print("日次リマインダーをスケジュールしました: \(hour)時")
        } catch {
            print("通知スケジュールエラー: \(error)")
        }
    }

    /// 週間サマリー通知をスケジュール
    func scheduleWeeklySummary(on weekday: Int = 1, at hour: Int = 9) async {
        guard isNotificationEnabled else {
            print("通知が有効ではありません")
            return
        }

        // 既存の通知をキャンセル
        center.removePendingNotificationRequests(withIdentifiers: ["weekly_summary"])

        // 通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = "今週の学習サマリー 📊"
        content.body = "今週の成果を確認しましょう"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "LEARNING_REMINDER"

        // トリガーの作成（毎週月曜日の9時）
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        dateComponents.weekday = weekday // 1 = 日曜日, 2 = 月曜日, ...

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        // 通知リクエストの作成
        let request = UNNotificationRequest(
            identifier: "weekly_summary",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            print("週間サマリーをスケジュールしました: \(weekday)曜日 \(hour)時)")
        } catch {
            print("通知スケジュールエラー: \(error)")
        }
    }

    /// 即時通知を送信
    /// - Parameters:
    ///   - title: タイトル
    ///   - body: 本文
    func sendImmediateNotification(title: String, body: String) async {
        guard isNotificationEnabled else {
            print("通知が有効ではありません")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("即時通知エラー: \(error)")
        }
    }

    // MARK: - Cancel Notifications

    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_learning_reminder"])
        print("日次リマインダーをキャンセルしました")
    }

    func cancelWeeklySummary() {
        center.removePendingNotificationRequests(withIdentifiers: ["weekly_summary"])
        print("週間サマリーをキャンセルしました")
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        print("すべての通知をキャンセルしました")
    }

    // MARK: - Badge Management

    func clearBadge() {
        center.setBadgeCount(0)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: @preconcurrency UNUserNotificationCenterDelegate {
    /// フォアグラウンドで通知を受信したときの処理
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // フォアグラウンドでも通知を表示
        completionHandler([.banner, .sound, .badge])
    }

    /// 通知をタップしたときの処理
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let _ = response.notification.request.content.userInfo

        // アクション識別子をチェック
        let actionIdentifier = response.actionIdentifier

        switch actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // 通知本体をタップした場合
            let identifier = response.notification.request.identifier
            print("通知がタップされました: \(identifier)")

            switch identifier {
            case "daily_learning_reminder":
                handleDailyReminderTap()
            case "weekly_summary":
                handleWeeklySummaryTap()
            default:
                break
            }

        case "LEARN_NOW":
            // 「今すぐ学習」アクションボタンをタップした場合
            print("「今すぐ学習」がタップされました")
            handleLearnNowAction()

        case "REMIND_LATER":
            // 「後で通知」アクションボタンをタップした場合
            print("「後で通知」がタップされました")
            handleRemindLaterAction()

        default:
            break
        }

        completionHandler()
    }

    private func handleLearnNowAction() {
        // 学習ログ画面に遷移
        print("学習ログ画面に遷移します")
        Task { @MainActor in
            NavigationViewModel.shared.selectedTab = 0 // LearningLogタブ
        }
    }

    private func handleRemindLaterAction() {
        // 30分後に再通知
        print("30分後に再通知します")
        Task {
            await sendImmediateNotification(title: "学習リマインダー", body: "学習の時間です！")
        }
    }

    private func handleDailyReminderTap() {
        // 学習ログ画面に遷移
        // NavigationViewModelを通じてタブを切り替え
        print("学習ログ画面に遷移します")
        Task { @MainActor in
            NavigationViewModel.shared.selectedTab = 0 // LearningLogタブ
        }
    }

    private func handleWeeklySummaryTap() {
        // 統計画面に遷移
        print("統計画面に遷移します")
        Task { @MainActor in
            NavigationViewModel.shared.selectedTab = 2 // Statisticsタブ
        }
    }
}

// MARK: - Notification Categories

extension NotificationService {
    /// 通知カテゴリの設定
    func setupNotificationCategories() async {
        let action1 = UNNotificationAction(
            identifier: "LEARN_NOW",
            title: "今すぐ学習",
            options: .foreground
        )

        let action2 = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "後で通知",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: "LEARNING_REMINDER",
            actions: [action1, action2],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([category])
    }
}
