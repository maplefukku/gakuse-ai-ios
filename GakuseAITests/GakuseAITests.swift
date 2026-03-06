import Testing
@testable import GakuseAI

struct GakuseAITests {
    @Test func testLearningLogCreation() async throws {
        let log = LearningLog(
            title: "テストログ",
            description: "これはテストです",
            category: .programming
        )
        
        #expect(log.title == "テストログ")
        #expect(log.description == "これはテストです")
        #expect(log.category == .programming)
        #expect(log.isPublic == false)
        #expect(log.skills.isEmpty)
        #expect(log.reflections.isEmpty)
    }
    
    @Test func testSkillCreation() async throws {
        let skill = Skill(name: "Swift", level: .intermediate)
        
        #expect(skill.name == "Swift")
        #expect(skill.level == .intermediate)
    }
    
    @Test func testReflectionCreation() async throws {
        let reflection = Reflection(
            content: "学んだことのテスト",
            type: .learning
        )
        
        #expect(reflection.content == "学んだことのテスト")
        #expect(reflection.type == .learning)
    }
}

// MARK: - PersistenceService Tests

struct PersistenceServiceTests {
    
    @Test func testSaveAndLoadLearningLogs() async throws {
        let service = PersistenceService.shared
        
        // テストデータを作成
        let logs = [
            LearningLog(title: "テスト1", description: "説明1", category: .programming),
            LearningLog(title: "テスト2", description: "説明2", category: .design)
        ]
        
        // 保存
        try await service.saveLearningLogs(logs)
        
        // 読み込み
        let loadedLogs = try await service.loadLearningLogs()
        
        #expect(loadedLogs.count == 2)
        #expect(loadedLogs[0].title == "テスト1")
        #expect(loadedLogs[1].title == "テスト2")
        
        // クリーンアップ
        try await service.deleteAllData()
    }
    
    @Test func testAppendLearningLog() async throws {
        let service = PersistenceService.shared
        
        // クリーンアップしてから開始
        try await service.deleteAllData()
        
        let log = LearningLog(title: "追加テスト", description: "追加説明", category: .business)
        try await service.appendLearningLog(log)
        
        let logs = try await service.loadLearningLogs()
        #expect(logs.count == 1)
        #expect(logs[0].title == "追加テスト")
        
        // クリーンアップ
        try await service.deleteAllData()
    }
    
    @Test func testDeleteLearningLog() async throws {
        let service = PersistenceService.shared
        
        // クリーンアップしてから開始
        try await service.deleteAllData()
        
        let log1 = LearningLog(title: "削除テスト1", description: "", category: .programming)
        let log2 = LearningLog(title: "削除テスト2", description: "", category: .design)
        
        try await service.appendLearningLog(log1)
        try await service.appendLearningLog(log2)
        
        // log1を削除
        try await service.deleteLearningLog(id: log1.id)
        
        let logs = try await service.loadLearningLogs()
        #expect(logs.count == 1)
        #expect(logs[0].title == "削除テスト2")
        
        // クリーンアップ
        try await service.deleteAllData()
    }
    
    @Test func testUserProfileSaveAndLoad() async throws {
        let service = PersistenceService.shared
        
        var profile = UserProfile(name: "テストユーザー")
        profile.email = "test@example.com"
        
        try await service.saveUserProfile(profile)
        
        let loadedProfile = try await service.loadUserProfile()
        
        #expect(loadedProfile?.name == "テストユーザー")
        #expect(loadedProfile?.email == "test@example.com")
        
        // クリーンアップ
        try await service.deleteAllData()
    }
    
    @Test func testExportData() async throws {
        let service = PersistenceService.shared
        
        // クリーンアップしてから開始
        try await service.deleteAllData()
        
        // テストデータを追加
        let log = LearningLog(title: "エクスポートテスト", description: "説明", category: .programming)
        try await service.appendLearningLog(log)
        
        // エクスポート実行
        let exportURL = try await service.exportAllData()
        
        // ファイルが存在することを確認
        #expect(FileManager.default.fileExists(atPath: exportURL.path))
        
        // JSONを読み込んで確認
        let data = try Data(contentsOf: exportURL)
        let exportData = try JSONDecoder().decode(ExportData.self, from: data)
        
        #expect(exportData.learningLogs.count == 1)
        #expect(exportData.learningLogs[0].title == "エクスポートテスト")
        
        // クリーンアップ
        try await service.deleteAllData()
    }
}

// MARK: - UserSettings Tests

struct UserSettingsTests {
    
    @Test func testDefaultSettings() async throws {
        let settings = UserSettings()
        
        #expect(settings.notificationsEnabled == true)
        #expect(settings.theme == .system)
        #expect(settings.autoSaveEnabled == true)
    }
    
    @Test func testThemeCoding() async throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for theme in [AppTheme.system, .light, .dark] {
            var settings = UserSettings()
            settings.theme = theme
            
            let data = try encoder.encode(settings)
            let decoded = try decoder.decode(UserSettings.self, from: data)
            
            #expect(decoded.theme == theme)
        }
    }
}

// MARK: - ChatMessageData Tests

struct ChatMessageDataTests {
    
    @Test func testChatMessageCreation() async throws {
        let message = ChatMessageData(content: "テストメッセージ", isUser: true)
        
        #expect(message.content == "テストメッセージ")
        #expect(message.isUser == true)
        #expect(message.id != UUID())
    }
    
    @Test func testChatMessageCoding() async throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let message = ChatMessageData(content: "エンコードテスト", isUser: false)
        
        let data = try encoder.encode(message)
        let decoded = try decoder.decode(ChatMessageData.self, from: data)
        
        #expect(decoded.content == "エンコードテスト")
        #expect(decoded.isUser == false)
    }
}

// MARK: - LearningLog Update Tests

struct LearningLogUpdateTests {
    
    @Test func testLearningLogCreatedAtIsImmutable() async throws {
        let originalCreatedAt = Date()
        let log = LearningLog(
            title: "テスト",
            description: "説明",
            category: .programming
        )
        
        // createdAtが設定されていることを確認
        #expect(log.createdAt.timeIntervalSince(originalCreatedAt) < 1.0)
        
        // スキルとリフレクションを追加
        var updatedLog = log
        updatedLog.skills.append(Skill(name: "Swift", level: .intermediate))
        updatedLog.reflections.append(Reflection(content: "学んだこと", type: .learning))
        
        // createdAtは不変であるべき
        #expect(updatedLog.createdAt == log.createdAt)
        
        // updatedAtは更新可能であるべき
        #expect(updatedLog.updatedAt.timeIntervalSince(log.updatedAt) >= 0)
    }
    
    @Test func testLearningLogFullInitializer() async throws {
        let createdAt = Date(timeIntervalSince1970: 1000)
        let updatedAt = Date(timeIntervalSince1970: 2000)
        let skills = [Skill(name: "Swift", level: .advanced)]
        let reflections = [Reflection(content: "テスト", type: .learning)]
        
        let log = LearningLog(
            id: UUID(),
            title: "フルイニシャライザ",
            description: "説明",
            category: .programming,
            isPublic: true,
            createdAt: createdAt,
            updatedAt: updatedAt,
            skills: skills,
            reflections: reflections
        )
        
        #expect(log.createdAt == createdAt)
        #expect(log.updatedAt == updatedAt)
        #expect(log.skills.count == 1)
        #expect(log.reflections.count == 1)
        #expect(log.isPublic == true)
    }
}

// MARK: - PortfolioViewModel Tests

struct PortfolioViewModelTests {
    
    @Test func testWeeklyDataCalculation() async throws {
        let calendar = Calendar.current
        let today = Date()
        
        // 過去7日間のテストデータを作成
        var testLogs: [LearningLog] = []
        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }
            
            // 各曜日1つのログを作成
            var log = LearningLog(
                title: "ログ\(dayOffset)",
                description: "説明",
                category: .programming,
                isPublic: true
            )
            // createdAtを上書き（フルイニシャライザを使用）
            log = LearningLog(
                id: log.id,
                title: log.title,
                description: log.description,
                category: log.category,
                isPublic: log.isPublic,
                createdAt: targetDate,
                updatedAt: log.updatedAt,
                skills: log.skills,
                reflections: log.reflections
            )
            testLogs.append(log)
        }
        
        // PersistenceServiceをモックしてテストデータを設定
        let service = PersistenceService.shared
        try await service.saveLearningLogs(testLogs)
        
        // PortfolioViewModelを作成
        @MainActor
        func testViewModel() async {
            let viewModel = PortfolioViewModel()
            await viewModel.loadData()
            
            // 過去7日間のデータが取得されていることを確認
            let weeklyData = viewModel.weeklyData
            let totalCount = weeklyData.reduce(0) { $0 + $1.count }
            
            // すべての曜日で1つずつ、合計7つのログがあるはず
            #expect(totalCount == 7)
        }
        
        await testViewModel()
        
        // クリーンアップ
        try await service.deleteAllData()
    }
    
    @Test func testWeeklyDataWithNoLogs() async throws {
        @MainActor
        func testViewModel() async {
            let viewModel = PortfolioViewModel()
            
            // ログがない場合、すべての曜日のカウントが0であることを確認
            let weeklyData = viewModel.weeklyData
            for data in weeklyData {
                #expect(data.count == 0)
            }
        }
        
        await testViewModel()
    }
    
    @Test func testStreakDaysCalculation() async throws {
        let calendar = Calendar.current
        let today = Date()
        
        // 過去5日間連続でログを作成
        var testLogs: [LearningLog] = []
        for dayOffset in 0..<5 {
            guard let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }
            
            var log = LearningLog(
                title: "ログ\(dayOffset)",
                description: "説明",
                category: .programming,
                isPublic: true
            )
            log = LearningLog(
                id: log.id,
                title: log.title,
                description: log.description,
                category: log.category,
                isPublic: log.isPublic,
                createdAt: targetDate,
                updatedAt: log.updatedAt,
                skills: log.skills,
                reflections: log.reflections
            )
            testLogs.append(log)
        }
        
        let service = PersistenceService.shared
        try await service.saveLearningLogs(testLogs)
        
        @MainActor
        func testViewModel() async {
            let viewModel = PortfolioViewModel()
            await viewModel.loadData()
            
            // 連続5日間のログがあるので、ストリークは5日であるべき
            #expect(viewModel.streakDays == 5)
        }
        
        await testViewModel()
        
        // クリーンアップ
        try await service.deleteAllData()
    }
}

// MARK: - APIService Tests

struct APIServiceTests {
    
    @Test func testAPIErrorDescriptions() async throws {
        #expect(APIError.unauthenticated.errorDescription == "認証が必要です")
        #expect(APIError.invalidResponse.errorDescription == "無効なレスポンスです")
        #expect(APIError.httpError(statusCode: 404).errorDescription == "HTTPエラー: 404")
        #expect(APIError.unknown.errorDescription == "不明なエラー")
    }
    
    @Test func testSendChatMessageMock() async throws {
        let service = APIService.shared
        
        // モックレスポンスをテスト
        let response = try await service.sendChatMessage("目標を立てたい", history: [])
        
        #expect(response.isUser == false)
        #expect(response.content.contains("なぜ"))
    }
    
    @Test func testSendChatMessageWithContext() async throws {
        let service = APIService.shared
        
        // チャット履歴を含めたテスト
        let history = [
            ChatMessageData(content: "プロジェクトを始めました", isUser: true),
            ChatMessageData(content: "素晴らしいですね！", isUser: false)
        ]
        
        let response = try await service.sendChatMessage("計画を立てたい", history: history)
        
        #expect(response.isUser == false)
        #expect(!response.content.isEmpty)
    }
}


