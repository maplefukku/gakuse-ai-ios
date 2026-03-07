import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let persistenceService = PersistenceService.shared
    
    init() {
        Task {
            await loadProfile()
        }
    }
    
    // MARK: - Profile Management
    
    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            userProfile = try await persistenceService.loadUserProfile()
            
            // 初回はデフォルトプロファイルを作成
            if userProfile == nil {
                let newProfile = UserProfile(name: "ユーザー")
                try await persistenceService.saveUserProfile(newProfile)
                userProfile = newProfile
            }
        } catch {
            errorMessage = "プロファイル読み込みエラー: \(error.localizedDescription)"
            print("プロファイル読み込みエラー: \(error)")
        }
    }
    
    func updateProfile(name: String) async {
        guard var profile = userProfile else { return }
        
        profile.name = name
        
        do {
            try await persistenceService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            errorMessage = "プロファイル保存エラー: \(error.localizedDescription)"
            print("プロファイル保存エラー: \(error)")
        }
    }
    
    func updateProfile(name: String, email: String?) async {
        guard var profile = userProfile else { return }
        
        profile.name = name
        profile.email = email
        
        do {
            try await persistenceService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            errorMessage = "プロファイル保存エラー: \(error.localizedDescription)"
            print("プロファイル保存エラー: \(error)")
        }
    }
    
    func updateProfile(name: String, avatarIcon: String) async {
        guard var profile = userProfile else { return }
        
        profile.name = name
        profile.avatarIcon = avatarIcon
        
        do {
            try await persistenceService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            errorMessage = "プロファイル保存エラー: \(error.localizedDescription)"
            print("プロファイル保存エラー: \(error)")
        }
    }
    
    // MARK: - Settings Management
    
    func updateSettings(_ settings: UserSettings) async {
        guard var profile = userProfile else { return }
        
        profile.settings = settings
        
        do {
            try await persistenceService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            errorMessage = "設定保存エラー: \(error.localizedDescription)"
            print("設定保存エラー: \(error)")
        }
    }
    
    func updateTheme(_ theme: AppTheme) async {
        guard var profile = userProfile else { return }
        
        profile.settings.theme = theme
        
        do {
            try await persistenceService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            errorMessage = "テーマ保存エラー: \(error.localizedDescription)"
            print("テーマ保存エラー: \(error)")
        }
    }
    
    func updateNotificationTime(_ time: DateComponents) async {
        guard var profile = userProfile else { return }
        
        profile.settings.notificationTime = time
        
        do {
            try await persistenceService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            errorMessage = "通知時間保存エラー: \(error.localizedDescription)"
            print("通知時間保存エラー: \(error)")
        }
    }
    
    func updateLanguage(_ language: AppLanguage) async {
        guard var profile = userProfile else { return }
        
        profile.settings.language = language
        
        do {
            try await persistenceService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            errorMessage = "言語設定保存エラー: \(error.localizedDescription)"
            print("言語設定保存エラー: \(error)")
        }
    }
    
    // MARK: - Data Management
    
    func exportAllData() async throws -> URL {
        // 学習ログをエクスポート
        let logs = try await persistenceService.loadLearningLogs()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let logsData = try encoder.encode(logs)
        
        // ファイル名を作成
        let fileName = "gakuse_ai_export_\(Date().timeIntervalSince1970).json"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        // 書き込み
        try logsData.write(to: path)
        
        return path
    }
    
    func deleteAllData() async {
        do {
            try await persistenceService.deleteAllData()
            userProfile = nil
            // 新規プロファイルを作成
            await loadProfile()
        } catch {
            errorMessage = "データ削除エラー: \(error.localizedDescription)"
            print("データ削除エラー: \(error)")
        }
    }
    
    // MARK: - Helper
    
    var formattedNotificationTime: String {
        guard let time = userProfile?.settings.notificationTime else {
            return "09:00"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        
        if let hour = time.hour, let minute = time.minute {
            if let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) {
                return formatter.string(from: date)
            }
        }
        
        return "09:00"
    }
}
