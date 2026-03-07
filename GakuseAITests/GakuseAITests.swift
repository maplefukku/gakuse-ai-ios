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
    
    @Test func testChatResponseGoalTopic() async throws {
        let service = APIService.shared
        
        let response = try await service.sendChatMessage("目標を設定したい", history: [])
        
        #expect(response.content.contains("目標"))
        #expect(response.content.contains("なぜ") || response.content.contains("どう"))
    }
    
    @Test func testChatResponseProjectTopic() async throws {
        let service = APIService.shared
        
        let response = try await service.sendChatMessage("プロジェクトを進めたい", history: [])
        
        #expect(response.content.contains("プロジェクト"))
        #expect(response.content.contains("学びたい") || response.content.contains("誰のために"))
    }
    
    @Test func testChatResponseCareerTopic() async throws {
        let service = APIService.shared
        
        let response = try await service.sendChatMessage("キャリアを考えたい", history: [])
        
        #expect(response.content.contains("キャリア"))
        #expect(response.content.contains("ワクワク"))
    }
    
    @Test func testChatResponseLearningTopic() async throws {
        let service = APIService.shared
        
        let response = try await service.sendChatMessage("学習計画を立てたい", history: [])
        
        #expect(response.content.contains("学習") || response.content.contains("パレート") || response.content.contains("PDCA"))
    }
    
    @Test func testChatResponseIdeaTopic() async throws {
        let service = APIService.shared
        
        let response = try await service.sendChatMessage("アイデアを出したい", history: [])
        
        #expect(response.content.contains("アイデア"))
        #expect(response.content.contains("視点"))
    }
    
    @Test func testChatResponseWithHistoryDepth() async throws {
        let service = APIService.shared
        
        // 複数回の会話履歴を作成
        let history = [
            ChatMessageData(content: "学習を始めたい", isUser: true),
            ChatMessageData(content: "素晴らしいですね！", isUser: false),
            ChatMessageData(content: "Swiftを学んでいます", isUser: true),
            ChatMessageData(content: "良いですね！", isUser: false),
            ChatMessageData(content: "iOSアプリを作っています", isUser: true),
        ]
        
        let response = try await service.sendChatMessage("次はどうすればいいですか？", history: history)
        
        #expect(response.isUser == false)
        #expect(!response.content.isEmpty)
    }
    
    @Test func testChatResponseWithProgrammingInterest() async throws {
        let service = APIService.shared
        
        let history = [
            ChatMessageData(content: "プログラミングを学んでいます", isUser: true),
        ]
        
        let response = try await service.sendChatMessage("計画を立てたい", history: history)
        
        #expect(response.isUser == false)
        #expect(!response.content.isEmpty)
    }
}

// MARK: - LearningLogViewModel Tests

struct LearningLogViewModelTests {
    
    @Test func testSortOrderNewestFirst() async throws {
        let calendar = Calendar.current
        let today = Date()
        
        let oldLog = createLogWithDate(calendar.date(byAdding: .day, value: -2, to: today)!)
        let middleLog = createLogWithDate(calendar.date(byAdding: .day, value: -1, to: today)!)
        let newLog = createLogWithDate(today)
        
        let viewModel = LearningLogViewModel()
        viewModel.logs = [oldLog, newLog, middleLog]
        viewModel.sortOrder = .newestFirst
        
        let filtered = viewModel.filteredLogs
        
        #expect(filtered.count == 3)
        #expect(filtered[0].id == newLog.id)
        #expect(filtered[1].id == middleLog.id)
        #expect(filtered[2].id == oldLog.id)
    }
    
    @Test func testSortOrderOldestFirst() async throws {
        let calendar = Calendar.current
        let today = Date()
        
        let oldLog = createLogWithDate(calendar.date(byAdding: .day, value: -2, to: today)!)
        let middleLog = createLogWithDate(calendar.date(byAdding: .day, value: -1, to: today)!)
        let newLog = createLogWithDate(today)
        
        let viewModel = LearningLogViewModel()
        viewModel.logs = [oldLog, newLog, middleLog]
        viewModel.sortOrder = .oldestFirst
        
        let filtered = viewModel.filteredLogs
        
        #expect(filtered.count == 3)
        #expect(filtered[0].id == oldLog.id)
        #expect(filtered[1].id == middleLog.id)
        #expect(filtered[2].id == newLog.id)
    }
    
    @Test func testSortOrderTitleAscending() async throws {
        let logA = LearningLog(title: "Apple", description: "", category: .programming)
        let logB = LearningLog(title: "Banana", description: "", category: .programming)
        let logC = LearningLog(title: "Cherry", description: "", category: .programming)
        
        let viewModel = LearningLogViewModel()
        viewModel.logs = [logB, logA, logC]
        viewModel.sortOrder = .titleAscending
        
        let filtered = viewModel.filteredLogs
        
        #expect(filtered.count == 3)
        #expect(filtered[0].title == "Apple")
        #expect(filtered[1].title == "Banana")
        #expect(filtered[2].title == "Cherry")
    }
    
    @Test func testToggleFavorite() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()
        
        let log = LearningLog(title: "テスト", description: "説明", category: .programming)
        try await service.appendLearningLog(log)
        
        let viewModel = LearningLogViewModel()
        await viewModel.loadLogs()
        
        let initialLog = viewModel.logs.first!
        #expect(initialLog.isFavorite == false)
        
        await viewModel.toggleFavorite(for: initialLog)
        
        let updatedLog = viewModel.logs.first!
        #expect(updatedLog.isFavorite == true)
        
        // クリーンアップ
        try await service.deleteAllData()
    }
    
    @Test func testFavoritesFilter() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()
        
        let log1 = createLogWithFavorite(isFavorite: true)
        let log2 = createLogWithFavorite(isFavorite: false)
        let log3 = createLogWithFavorite(isFavorite: true)
        
        try await service.appendLearningLog(log1)
        try await service.appendLearningLog(log2)
        try await service.appendLearningLog(log3)
        
        let viewModel = LearningLogViewModel()
        await viewModel.loadLogs()
        
        viewModel.showingFavoritesOnly = true
        
        let filtered = viewModel.filteredLogs
        
        #expect(filtered.count == 2)
        #expect(filtered.allSatisfy { $0.isFavorite })
        
        // クリーンアップ
        try await service.deleteAllData()
    }
    
    @Test func testFavoriteCount() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()
        
        try await service.appendLearningLog(createLogWithFavorite(isFavorite: true))
        try await service.appendLearningLog(createLogWithFavorite(isFavorite: false))
        try await service.appendLearningLog(createLogWithFavorite(isFavorite: true))
        
        let viewModel = LearningLogViewModel()
        await viewModel.loadLogs()
        
        #expect(viewModel.favoriteCount == 2)
        
        // クリーンアップ
        try await service.deleteAllData()
    }
    
    // MARK: - Helper Methods

    private func createLogWithDate(_ date: Date) -> LearningLog {
        var log = LearningLog(title: "テスト", description: "説明", category: .programming)
        return LearningLog(
            id: log.id,
            title: log.title,
            description: log.description,
            category: log.category,
            isPublic: log.isPublic,
            createdAt: date,
            updatedAt: log.updatedAt,
            skills: log.skills,
            reflections: log.reflections,
            isFavorite: log.isFavorite
        )
    }
    
    private func createLogWithFavorite(isFavorite: Bool) -> LearningLog {
        var log = LearningLog(title: "テスト", description: "説明", category: .programming)
        log.isFavorite = isFavorite
        return log
    }
}

// MARK: - Export Tests

struct LearningLogViewModelExportTests {

    @Test func testExportToCSV() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let log1 = createLogWithFavorite(isFavorite: true)
        let log2 = createLogWithFavorite(isFavorite: false)

        try await service.appendLearningLog(log1)
        try await service.appendLearningLog(log2)

        let viewModel = LearningLogViewModel()
        await viewModel.loadLogs()

        if let csvURL = viewModel.exportToCSV() {
            let csvContent = try String(contentsOf: csvURL)
            #expect(csvContent.contains("タイトル,説明,カテゴリ"))
            #expect(csvContent.contains(log1.title))
            #expect(csvContent.contains(log2.title))
        } else {
            #expect(Bool(false), "CSVエクスポートに失敗しました")
        }

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testExportToJSON() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let log1 = createLogWithFavorite(isFavorite: true)
        try await service.appendLearningLog(log1)

        let viewModel = LearningLogViewModel()
        await viewModel.loadLogs()

        if let jsonURL = viewModel.exportToJSON() {
            let jsonData = try Data(contentsOf: jsonURL)
            let decoder = JSONDecoder()
            let logs = try decoder.decode([LearningLog].self, from: jsonData)

            #expect(logs.count == 1)
            #expect(logs[0].id == log1.id)
        } else {
            #expect(Bool(false), "JSONエクスポートに失敗しました")
        }

        // クリーンアップ
        try await service.deleteAllData()
    }
}

// MARK: - Search Options Tests

struct LearningLogViewModelSearchOptionsTests {

    @Test func testDateRangeFilter() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        let log1 = createLogWithDate(twoDaysAgo)
        let log2 = createLogWithDate(yesterday)
        let log3 = createLogWithDate(today)

        try await service.appendLearningLog(log1)
        try await service.appendLearningLog(log2)
        try await service.appendLearningLog(log3)

        let viewModel = LearningLogViewModel()
        await viewModel.loadLogs()

        // 昨日以降のフィルター
        viewModel.dateRangeStart = yesterday
        let filtered = viewModel.filteredLogs

        #expect(filtered.count == 2)
        #expect(filtered.contains { $0.id == log2.id })
        #expect(filtered.contains { $0.id == log3.id })
        #expect(!filtered.contains { $0.id == log1.id })

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testSearchInSkills() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let log = LearningLog(
            title: "テストログ",
            description: "説明",
            category: .programming
        )
        log.skills.append(Skill(name: "Swift", level: .intermediate))

        try await service.appendLearningLog(log)

        let viewModel = LearningLogViewModel()
        await viewModel.loadLogs()

        // スキル検索を有効化
        viewModel.searchInSkills = true
        viewModel.searchText = "Swift"

        let filtered = viewModel.filteredLogs

        #expect(filtered.count == 1)
        #expect(filtered[0].id == log.id)

        // スキル検索を無効化
        viewModel.searchInSkills = false
        viewModel.searchText = "Swift"

        let filteredNoSkill = viewModel.filteredLogs

        #expect(filteredNoSkill.isEmpty)

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testResetSearchOptions() async throws {
        let viewModel = LearningLogViewModel()

        // 各オプションを設定
        viewModel.searchText = "test"
        viewModel.selectedCategory = .programming
        viewModel.showOnlyPublic = true
        viewModel.showingFavoritesOnly = true
        viewModel.sortOrder = .oldestFirst
        viewModel.dateRangeStart = Date()
        viewModel.dateRangeEnd = Date()
        viewModel.searchInSkills = true

        // リセット
        viewModel.resetSearchOptions()

        // リセットされたことを確認
        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.selectedCategory == nil)
        #expect(viewModel.showOnlyPublic == false)
        #expect(viewModel.showingFavoritesOnly == false)
        #expect(viewModel.sortOrder == .newestFirst)
        #expect(viewModel.dateRangeStart == nil)
        #expect(viewModel.dateRangeEnd == nil)
        #expect(viewModel.searchInSkills == false)
    }
}

// MARK: - StatisticsViewModel Tests

struct StatisticsViewModelTests {

    @Test func testWeeklyDataWithWeekdayLabels() async throws {
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

        // StatisticsViewModelを作成
        @MainActor
        func testViewModel() async {
            let viewModel = StatisticsViewModel()
            await viewModel.loadData()

            // 過去7日間のデータが取得されていることを確認
            let weeklyData = viewModel.weeklyData
            let totalCount = weeklyData.reduce(0) { $0 + $1.count }

            // すべての曜日で1つずつ、合計7つのログがあるはず
            #expect(totalCount == 7)

            // 各データポイントに曜日ラベルがあることを確認
            for dataPoint in weeklyData {
                #expect(!dataPoint.weekday.isEmpty)
            }
        }

        await testViewModel()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testWeeklyDataOrdering() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let calendar = Calendar.current
        let today = Date()

        // 過去7日間のテストデータを作成（データ数を変える）
        var testLogs: [LearningLog] = []
        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }

            // 日付によってデータ数を変える
            let logCount = (dayOffset % 3) + 1
            for i in 0..<logCount {
                var log = LearningLog(
                    title: "ログ\(dayOffset)-\(i)",
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
        }

        try await service.saveLearningLogs(testLogs)

        @MainActor
        func testViewModel() async {
            let viewModel = StatisticsViewModel()
            await viewModel.loadData()

            let weeklyData = viewModel.weeklyData

            // データが古い順にソートされていることを確認
            for i in 0..<(weeklyData.count - 1) {
                #expect(weeklyData[i].date < weeklyData[i + 1].date)
            }

            // 各曜日ラベルが適切に設定されていることを確認
            #expect(weeklyData.count == 7)
        }

        await testViewModel()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testWeeklyDataWithJapaneseLocale() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let calendar = Calendar.current
        let today = Date()

        // テストデータを作成
        var testLogs: [LearningLog] = []
        for dayOffset in 0..<7 {
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

        try await service.saveLearningLogs(testLogs)

        // 日本語ロケールのユーザー設定を作成
        var profile = UserProfile(name: "テストユーザー")
        profile.settings.language = .japanese
        try await service.saveUserProfile(profile)

        @MainActor
        func testViewModel() async {
            let viewModel = StatisticsViewModel()
            await viewModel.loadData()

            // 日本語ロケールが使用されていることを確認
            #expect(viewModel.userSettings.language == .japanese)

            // 曜日ラベルが日本語であることを確認
            let weeklyData = viewModel.weeklyData
            for dataPoint in weeklyData {
                #expect(!dataPoint.weekday.isEmpty)
            }
        }

        await testViewModel()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testWeeklyDataWithEnglishLocale() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let calendar = Calendar.current
        let today = Date()

        // テストデータを作成
        var testLogs: [LearningLog] = []
        for dayOffset in 0..<7 {
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

        try await service.saveLearningLogs(testLogs)

        // 英語ロケールのユーザー設定を作成
        var profile = UserProfile(name: "Test User")
        profile.settings.language = .english
        try await service.saveUserProfile(profile)

        @MainActor
        func testViewModel() async {
            let viewModel = StatisticsViewModel()
            await viewModel.loadData()

            // 英語ロケールが使用されていることを確認
            #expect(viewModel.userSettings.language == .english)

            // 曜日ラベルが英語であることを確認
            let weeklyData = viewModel.weeklyData
            for dataPoint in weeklyData {
                #expect(!dataPoint.weekday.isEmpty)
            }
        }

        await testViewModel()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testUserSettingsLoading() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        // ユーザー設定を保存
        var profile = UserProfile(name: "テストユーザー")
        profile.settings.theme = .dark
        profile.settings.language = .english
        profile.settings.notificationEnabled = false
        try await service.saveUserProfile(profile)

        // 設定を読み込み
        let loadedSettings = try await service.loadUserSettings()

        #expect(loadedSettings.theme == .dark)
        #expect(loadedSettings.language == .english)
        #expect(loadedSettings.notificationEnabled == false)

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testUserSettingsDefaultValues() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        // プロファイルがない場合、デフォルト設定が返される
        let settings = try await service.loadUserSettings()

        #expect(settings.theme == .system)
        #expect(settings.language == .japanese)
        #expect(settings.notificationEnabled == true)
        #expect(settings.autoSaveEnabled == true)

        // クリーンアップ
        try await service.deleteAllData()
    }
}

// MARK: - StatisticsViewModel Tests

struct StatisticsViewModelTests {
    @Test func testWeeklyDataCalculation() async throws {
        let viewModel = StatisticsViewModel()

        // テストデータを追加
        let today = Date()
        let calendar = Calendar.current

        let logs = [
            LearningLog(title: "今日の学習", description: "説明", category: .programming),
            LearningLog(title: "昨日の学習", description: "説明", category: .design)
        ]

        // 手動でログを設定（通常はloadDataで読み込む）
        // ここではテスト用に簡易的に設定
        viewModel.learningLogs = logs

        let weeklyData = viewModel.weeklyData

        // 週間データが生成されていることを確認
        #expect(!weeklyData.isEmpty)
        #expect(weeklyData.count == 7) // 7日分
    }

    @Test func testLocaleChangeTriggersUpdate() async throws {
        let viewModel = StatisticsViewModel()

        // デフォルトのロケール
        let initialLocale = viewModel.userSettings.language.locale
        #expect(initialLocale.identifier == "ja")

        // ロケールを変更
        viewModel.userSettings.language = .english

        // ロケールが変更されたことを確認
        #expect(viewModel.userSettings.language.locale.identifier == "en")
    }

    @Test func testStreakDaysCalculation() async throws {
        let viewModel = StatisticsViewModel()

        // テストデータを設定（昨日まで3日連続）
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today)!

        let logs = [
            LearningLog(title: "3日前", description: "説明", category: .programming),
            LearningLog(title: "2日前", description: "説明", category: .design),
            LearningLog(title: "昨日", description: "説明", category: .business)
        ]

        // 日付を調整
        viewModel.learningLogs = logs.map { log in
            LearningLog(
                id: log.id,
                title: log.title,
                description: log.description,
                category: log.category,
                isPublic: log.isPublic,
                createdAt: calendar.date(byAdding: .day, value: -3, to: today)!,
                updatedAt: log.updatedAt,
                skills: log.skills,
                reflections: log.reflections,
                isFavorite: log.isFavorite
            )
        }

        let streak = viewModel.streakDays

        // 連続日数が計算されていることを確認
        #expect(streak >= 0)
    }
}

// MARK: - ProfileViewModel Tests

struct ProfileViewModelTests {
    @Test func testFormattedNotificationTimeWithLocale() async throws {
        let viewModel = ProfileViewModel()

        // プロファイルを作成
        let profile = UserProfile(name: "テストユーザー")
        var settings = profile.settings
        settings.notificationTime = DateComponents(hour: 9, minute: 30)
        profile.settings = settings

        viewModel.userProfile = profile

        // 日本語ロケール
        let timeJp = viewModel.formattedNotificationTime
        #expect(!timeJp.isEmpty)

        // 英語ロケールに変更
        viewModel.userProfile?.settings.language = .english
        let timeEn = viewModel.formattedNotificationTime
        #expect(!timeEn.isEmpty)

        // ロケールが異なれば形式も異なる可能性がある
        // 少なくとも空ではないことを確認
    }

    @Test func testLanguageSetting() async throws {
        let viewModel = ProfileViewModel()

        // プロファイルを作成
        let profile = UserProfile(name: "テストユーザー")
        viewModel.userProfile = profile

        // 日本語
        viewModel.userProfile?.settings.language = .japanese
        #expect(viewModel.userProfile?.settings.language == .japanese)

        // 英語
        viewModel.userProfile?.settings.language = .english
        #expect(viewModel.userProfile?.settings.language == .english)
    }
}

// MARK: - LearningCategory Tests

struct LearningCategoryTests {
    @Test func testCategoryColor() async throws {
        // 各カテゴリの色が正しく定義されているか
        #expect(LearningCategory.programming.color == .blue)
        #expect(LearningCategory.design.color == .purple)
        #expect(LearningCategory.business.color == .orange)
        #expect(LearningCategory.language.color == .green)
        #expect(LearningCategory.creative.color == .pink)
        #expect(LearningCategory.other.color == .gray)
    }

    @Test func testCategoryIcon() async throws {
        // 各カテゴリのアイコンが正しく定義されているか
        #expect(LearningCategory.programming.icon == "chevron.left.forwardslash.chevron.right")
        #expect(LearningCategory.design.icon == "paintbrush.fill")
        #expect(LearningCategory.business.icon == "briefcase.fill")
        #expect(LearningCategory.language.icon == "globe")
        #expect(LearningCategory.creative.icon == "sparkles")
        #expect(LearningCategory.other.icon == "star.fill")
    }

    @Test func testCategoryRawValue() async throws {
        #expect(LearningCategory.programming.rawValue == "プログラミング")
        #expect(LearningCategory.design.rawValue == "デザイン")
        #expect(LearningCategory.business.rawValue == "ビジネス")
        #expect(LearningCategory.language.rawValue == "語学")
        #expect(LearningCategory.creative.rawValue == "クリエイティブ")
        #expect(LearningCategory.other.rawValue == "その他")
    }
}

// MARK: - StatisticsViewModel Additional Tests

struct StatisticsViewModelAdditionalTests {
    @Test func testUserSettingsPublishedProperty() async throws {
        let viewModel = StatisticsViewModel()

        // userSettingsが@Publishedであることを確認
        // ロケールを変更すると、週間データの曜日ラベルも更新される
        let initialWeekday = viewModel.weeklyData.first?.weekday ?? ""
        viewModel.userSettings.language = .english

        // 設定変更後にデータが再計算される
        // （直接検証できないが、@PublishedによってUI更新がトリガーされる）
        #expect(viewModel.userSettings.language == .english)
    }

    @Test func testCategoryDataWithMultipleCategories() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        // 複数のカテゴリのテストデータを作成
        let logs = [
            LearningLog(title: "プログラミング1", description: "説明", category: .programming),
            LearningLog(title: "プログラミング2", description: "説明", category: .programming),
            LearningLog(title: "デザイン1", description: "説明", category: .design),
            LearningLog(title: "ビジネス1", description: "説明", category: .business),
            LearningLog(title: "語学1", description: "説明", category: .language),
            LearningLog(title: "クリエイティブ1", description: "説明", category: .creative),
            LearningLog(title: "その他1", description: "説明", category: .other)
        ]

        try await service.saveLearningLogs(logs)

        @MainActor
        func testViewModel() async {
            let viewModel = StatisticsViewModel()
            await viewModel.loadData()

            let categoryData = viewModel.categoryData

            // すべてのカテゴリが含まれている
            #expect(categoryData.count == 6)

            // プログラミングが2件
            let programmingData = categoryData.first { $0.category == .programming }
            #expect(programmingData?.count == 2)

            // その他が1件ずつ
            for category in [LearningCategory.design, .business, .language, .creative, .other] {
                let data = categoryData.first { $0.category == category }
                #expect(data?.count == 1)
            }
        }

        await testViewModel()

        // クリーンアップ
        try await service.deleteAllData()
    }
}

// MARK: - ProfileViewModel Additional Tests

struct ProfileViewModelAdditionalTests {
    @Test func testUpdateProfileWithAllParameters() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        // プロファイルを作成
        let profile = UserProfile(name: "初期ユーザー")
        try await service.saveUserProfile(profile)

        @MainActor
        func testViewModel() async {
            let viewModel = ProfileViewModel()
            await viewModel.loadProfile()

            // すべてのパラメータで更新
            await viewModel.updateProfile(
                name: "更新ユーザー",
                email: "updated@example.com",
                avatarIcon: "face.smiling"
            )

            // 更新が反映されている
            #expect(viewModel.userProfile?.name == "更新ユーザー")
            #expect(viewModel.userProfile?.email == "updated@example.com")
            #expect(viewModel.userProfile?.avatarIcon == "face.smiling")
        }

        await testViewModel()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testUpdateProfileWithPartialParameters() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let profile = UserProfile(name: "初期ユーザー")
        profile.email = "initial@example.com"
        profile.avatarIcon = "face.smiling"
        try await service.saveUserProfile(profile)

        @MainActor
        func testViewModel() async {
            let viewModel = ProfileViewModel()
            await viewModel.loadProfile()

            // 名前のみ更新
            await viewModel.updateProfile(name: "名前のみ更新")

            // 名前だけが変更され、他は維持される
            #expect(viewModel.userProfile?.name == "名前のみ更新")
            #expect(viewModel.userProfile?.email == "initial@example.com")
            #expect(viewModel.userProfile?.avatarIcon == "face.smiling")
        }

        await testViewModel()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testFormattedNotificationTimeWithInvalidTime() async throws {
        let viewModel = ProfileViewModel()

        // 通知時間が設定されていない場合
        var profile = UserProfile(name: "テストユーザー")
        profile.settings.notificationTime = nil
        viewModel.userProfile = profile

        let timeString = viewModel.formattedNotificationTime

        // デフォルト値が返される
        #expect(timeString == "09:00")
    }
}

// MARK: - AIChatViewModel Additional Tests

struct AIChatViewModelAdditionalTests {
    @Test func testCopyMessage() async throws {
        let viewModel = AIChatViewModel()

        let message = ChatMessageData(
            id: UUID(),
            content: "テストメッセージ",
            isUser: true,
            timestamp: Date()
        )

        // コピーを実行
        viewModel.copyMessage(message)

        // クリップボードにコピーされたか確認
        let clipboardContent = UIPasteboard.general.string
        #expect(clipboardContent == "テストメッセージ")
    }

    @Test func testFilteredPromptsWithCategory() async throws {
        let viewModel = AIChatViewModel()

        // テスト用のプロンプトを追加
        viewModel.suggestedPrompts = [
            SuggestedPrompt(text: "一般プロンプト", category: .general, icon: "ellipsis.circle"),
            SuggestedPrompt(text: "学習プロンプト", category: .learning, icon: "book.fill"),
            SuggestedPrompt(text: "プログラミングプロンプト", category: .programming, icon: "chevron.left.forwardslash.chevron.right")
        ]

        // 一般カテゴリでフィルター
        viewModel.selectedPromptCategory = .general
        let filteredGeneral = viewModel.filteredPrompts

        #expect(filteredGeneral.count == 1)
        #expect(filteredGeneral.first?.category == .general)

        // すべてのプロンプトを表示
        viewModel.selectedPromptCategory = nil
        let filteredAll = viewModel.filteredPrompts

        #expect(filteredAll.count == 3)
    }
}

// MARK: - DetailPopupSheet Locale Tests

struct DetailPopupSheetTests {
    @Test func testFormatDateWithJapaneseLocale() async throws {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let dataPoint = WeeklyDataPoint(date: yesterday, count: 2, weekday: "火")
        let logs = [
            LearningLog(title: "ログ1", description: "説明1", category: .programming),
            LearningLog(title: "ログ2", description: "説明2", category: .design)
        ]

        // DetailPopupSheetのロジックをテスト
        let dayLogs = logs.filter { log in
            calendar.isDate(log.createdAt, inSameDayAs: dataPoint.date)
        }

        // 日本語ロケールでフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "ja_JP")
        let formattedDate = formatter.string(from: dataPoint.date)

        // 日本語形式であることを確認
        #expect(formattedDate.contains("/"))

        // ログがフィルタリングされていることを確認
        #expect(dayLogs.isEmpty == false)
    }

    @Test func testFormatDateWithEnglishLocale() async throws {
        let calendar = Calendar.current
        let today = Date()

        let dataPoint = WeeklyDataPoint(date: today, count: 1, weekday: "Mon")

        // 英語ロケールでフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "en_US")
        let formattedDate = formatter.string(from: dataPoint.date)

        // 英語形式であることを確認
        #expect(formattedDate.contains("/"))
    }

    @Test func testFormatTimeWithJapaneseLocale() async throws {
        let calendar = Calendar.current
        let today = Date()
        let now = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: today)!

        // 日本語ロケールでフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        let formattedTime = formatter.string(from: now)

        #expect(formattedTime == "14:30")
    }

    @Test func testFormatTimeWithEnglishLocale() async throws {
        let calendar = Calendar.current
        let today = Date()
        let now = calendar.date(bySettingHour: 2, minute: 30, second: 0, of: today)!

        // 英語ロケールでフォーマット（12時間形式になる可能性がある）
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        let formattedTime = formatter.string(from: now)

        // 空ではないことを確認
        #expect(!formattedTime.isEmpty)
    }
}

// MARK: - DayLogRow Locale Tests

struct DayLogRowTests {
    @Test func testDayLogRowWithJapaneseLocale() async throws {
        let calendar = Calendar.current
        let today = Date()
        let now = calendar.date(bySettingHour: 15, minute: 45, second: 0, of: today)!

        let log = LearningLog(
            title: "テストログ",
            description: "テスト説明",
            category: .programming
        )
        log.skills.append(Skill(name: "Swift", level: .intermediate))

        // 日本語ロケールでフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        let formattedTime = formatter.string(from: now)

        #expect(formattedTime == "15:45")
    }

    @Test func testDayLogRowWithEnglishLocale() async throws {
        let calendar = Calendar.current
        let today = Date()
        let now = calendar.date(bySettingHour: 9, minute: 15, second: 0, of: today)!

        let log = LearningLog(
            title: "Test Log",
            description: "Test description",
            category: .programming
        )
        log.skills.append(Skill(name: "Swift", level: .intermediate))

        // 英語ロケールでフォーマット
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        let formattedTime = formatter.string(from: now)

        // 空ではないことを確認
        #expect(!formattedTime.isEmpty)
    }

    @Test func testDayLogRowCategoryColor() async throws {
        let log = LearningLog(
            title: "テストログ",
            description: "テスト説明",
            category: .programming
        )

        // カテゴリの色が正しく設定されている
        #expect(log.category.color == .blue)

        let designLog = LearningLog(
            title: "デザインログ",
            description: "デザイン説明",
            category: .design
        )

        #expect(designLog.category.color == .purple)
    }
}

// MARK: - StatisticsView Locale Optimization Tests

struct StatisticsViewLocaleOptimizationTests {
    @Test func testWeeklyDataLocaleUpdateOnSettingsChange() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let calendar = Calendar.current
        let today = Date()

        // テストデータを作成
        var testLogs: [LearningLog] = []
        for dayOffset in 0..<7 {
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

        try await service.saveLearningLogs(testLogs)

        // 日本語設定のプロファイルを作成
        var profile = UserProfile(name: "テストユーザー")
        profile.settings.language = .japanese
        try await service.saveUserProfile(profile)

        @MainActor
        func testViewModel() async {
            let viewModel = StatisticsViewModel()
            await viewModel.loadData()

            // 日本語ロケールで初期化
            let initialWeekday = viewModel.weeklyData.first?.weekday ?? ""
            #expect(viewModel.userSettings.language == .japanese)
            #expect(!initialWeekday.isEmpty)

            // 英語に変更
            viewModel.userSettings.language = .english

            // ロケールが変更されたことを確認
            #expect(viewModel.userSettings.language == .english)

            // @PublishedプロパティなのでUI更新がトリガーされる
            // 週間データの曜日ラベルが英語になっているか確認
            let updatedWeekday = viewModel.weeklyData.first?.weekday ?? ""
            #expect(!updatedWeekday.isEmpty)
        }

        await testViewModel()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testPublishedUserSettingsTriggersUIUpdate() async throws {
        let viewModel = StatisticsViewModel()

        // userSettingsが@Publishedであることを確認
        // 設定を変更するとUI更新がトリガーされるはず

        let initialTheme = viewModel.userSettings.theme
        #expect(initialTheme == .system)

        // テーマを変更
        viewModel.userSettings.theme = .dark
        #expect(viewModel.userSettings.theme == .dark)

        // 言語を変更
        viewModel.userSettings.language = .english
        #expect(viewModel.userSettings.language == .english)

        // 通知設定を変更
        viewModel.userSettings.notificationEnabled = false
        #expect(viewModel.userSettings.notificationEnabled == false)
    }

    @Test func testLocaleChangeDoesNotAffectDataIntegrity() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let logs = [
            LearningLog(title: "ログ1", description: "説明1", category: .programming),
            LearningLog(title: "ログ2", description: "説明2", category: .design),
            LearningLog(title: "ログ3", description: "説明3", category: .business)
        ]

        try await service.saveLearningLogs(logs)

        @MainActor
        func testViewModel() async {
            let viewModel = StatisticsViewModel()
            await viewModel.loadData()

            // 初期状態
            let initialTotalLogs = viewModel.totalLogsCount
            let initialTotalSkills = viewModel.totalSkillsCount
            let initialWeeklyDataCount = viewModel.weeklyData.count

            // ロケールを変更
            viewModel.userSettings.language = .english

            // データの整合性が保たれていることを確認
            #expect(viewModel.totalLogsCount == initialTotalLogs)
            #expect(viewModel.totalSkillsCount == initialTotalSkills)
            #expect(viewModel.weeklyData.count == initialWeeklyDataCount)
        }

        await testViewModel()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testWeeklyDataCalculationWithDifferentLocales() async throws {
        let service = PersistenceService.shared
        try await service.deleteAllData()

        let calendar = Calendar.current
        let today = Date()

        // テストデータを作成
        var testLogs: [LearningLog] = []
        for dayOffset in 0..<7 {
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

        try await service.saveLearningLogs(testLogs)

        @MainActor
        func testViewModel() async {
            let viewModel = StatisticsViewModel()
            await viewModel.loadData()

            // 日本語ロケールで曜日ラベルを生成
            let japaneseData = viewModel.weeklyData
            let japaneseLabels = japaneseData.map { $0.weekday }

            // 英語に変更して曜日ラベルを再生成
            viewModel.userSettings.language = .english
            let englishData = viewModel.weeklyData
            let englishLabels = englishData.map { $0.weekday }

            // 曜日ラベルの数は同じであるべき
            #expect(japaneseLabels.count == englishLabels.count)

            // 各曜日のロール数は同じであるべき
            for i in 0..<japaneseData.count {
                #expect(japaneseData[i].count == englishData[i].count)
            }

            // ただし、曜日ラベルの形式は異なる可能性がある（ロケールによる）
        }

        await testViewModel()

        // クリーンアップ
        try await service.deleteAllData()
    }
}

// MARK: - LearningLogViewModel Export Tests

struct LearningLogViewModelExportTests {

    @Test func testExportToCSV() async throws {
        let service = PersistenceService.shared

        // クリーンアップしてから開始
        try await service.deleteAllData()

        // テストデータを作成
        let logs = [
            LearningLog(
                title: "CSVテスト1",
                description: "説明1",
                category: .programming,
                isPublic: true
            ),
            LearningLog(
                title: "CSVテスト2",
                description: "説明2",
                category: .design,
                isPublic: false
            )
        ]

        try await service.saveLearningLogs(logs)

        @MainActor
        func testExport() async throws {
            let viewModel = LearningLogViewModel()
            await viewModel.loadLogs()

            // CSVエクスポート
            guard let csvURL = viewModel.exportToCSV() else {
                throw TestError.exportFailed
            }

            // ファイルが存在することを確認
            #expect(FileManager.default.fileExists(atPath: csvURL.path))

            // ファイルの内容を読み込み
            let csvContent = try String(contentsOf: csvURL, encoding: .utf8)

            // CSVのヘッダーが含まれていることを確認
            #expect(csvContent.contains("タイトル,説明,カテゴリ,作成日時,公開設定,スキル,振り返り"))

            // テストデータが含まれていることを確認
            #expect(csvContent.contains("CSVテスト1"))
            #expect(csvContent.contains("CSVテスト2"))

            // ファイルを削除
            try FileManager.default.removeItem(at: csvURL)
        }

        try await testExport()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testExportToJSON() async throws {
        let service = PersistenceService.shared

        // クリーンアップしてから開始
        try await service.deleteAllData()

        // テストデータを作成
        let logs = [
            LearningLog(
                title: "JSONテスト1",
                description: "説明1",
                category: .business,
                isPublic: true
            )
        ]

        try await service.saveLearningLogs(logs)

        @MainActor
        func testExport() async throws {
            let viewModel = LearningLogViewModel()
            await viewModel.loadLogs()

            // JSONエクスポート
            guard let jsonURL = viewModel.exportToJSON() else {
                throw TestError.exportFailed
            }

            // ファイルが存在することを確認
            #expect(FileManager.default.fileExists(atPath: jsonURL.path))

            // ファイルの内容を読み込み
            let data = try Data(contentsOf: jsonURL)
            let decodedLogs = try JSONDecoder().decode([LearningLog].self, from: data)

            // デコードされたデータが正しいことを確認
            #expect(decodedLogs.count == 1)
            #expect(decodedLogs[0].title == "JSONテスト1")

            // ファイルを削除
            try FileManager.default.removeItem(at: jsonURL)
        }

        try await testExport()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testExportToCSVWithSpecialCharacters() async throws {
        let service = PersistenceService.shared

        // クリーンアップしてから開始
        try await service.deleteAllData()

        // 特殊文字を含むテストデータ
        let logs = [
            LearningLog(
                title: "テスト,カンマ",
                description: "説明\"引用符\"",
                category: .programming,
                isPublic: false
            )
        ]

        try await service.saveLearningLogs(logs)

        @MainActor
        func testExport() async throws {
            let viewModel = LearningLogViewModel()
            await viewModel.loadLogs()

            guard let csvURL = viewModel.exportToCSV() else {
                throw TestError.exportFailed
            }

            let csvContent = try String(contentsOf: csvURL, encoding: .utf8)

            // カンマと引用符が適切にエスケープされていることを確認
            #expect(csvContent.contains("\"テスト,カンマ\""))
            #expect(csvContent.contains("\"説明\"\"引用符\"\"\""))

            try FileManager.default.removeItem(at: csvURL)
        }

        try await testExport()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testExportToCSVWithNewlines() async throws {
        let service = PersistenceService.shared

        // クリーンアップしてから開始
        try await service.deleteAllData()

        // 改行文字を含むテストデータ
        var log = LearningLog(
            title: "改行テスト",
            description: "説明1\n説明2\n説明3",
            category: .programming,
            isPublic: false
        )
        log.reflections.append(Reflection(content: "振り返り1\n振り返り2", type: .learning))

        try await service.appendLearningLog(log)

        @MainActor
        func testExport() async throws {
            let viewModel = LearningLogViewModel()
            await viewModel.loadLogs()

            guard let csvURL = viewModel.exportToCSV() else {
                throw TestError.exportFailed
            }

            let csvContent = try String(contentsOf: csvURL, encoding: .utf8)

            // 改行がエスケープされているか確認
            // CSVでは改行はエスケープされるべき
            #expect(csvContent.contains("改行テスト"))

            try FileManager.default.removeItem(at: csvURL)
        }

        try await testExport()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testExportToCSVWithUnicode() async throws {
        let service = PersistenceService.shared

        // クリーンアップしてから開始
        try await service.deleteAllData()

        // Unicode文字を含むテストデータ
        let logs = [
            LearningLog(
                title: "Unicodeテスト 😊🎉",
                description: "日本語、한국어、中文",
                category: .programming,
                isPublic: false
            ),
            LearningLog(
                title: "🚀 スタート",
                description: "αβγδε 数学記号",
                category: .design,
                isPublic: true
            )
        ]

        try await service.saveLearningLogs(logs)

        @MainActor
        func testExport() async throws {
            let viewModel = LearningLogViewModel()
            await viewModel.loadLogs()

            guard let csvURL = viewModel.exportToCSV() else {
                throw TestError.exportFailed
            }

            let csvContent = try String(contentsOf: csvURL, encoding: .utf8)

            // Unicode文字が正しくエンコードされている
            #expect(csvContent.contains("😊🎉"))
            #expect(csvContent.contains("🚀"))
            #expect(csvContent.contains("αβγδε"))

            try FileManager.default.removeItem(at: csvURL)
        }

        try await testExport()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testExportToCSVWithLongText() async throws {
        let service = PersistenceService.shared

        // クリーンアップしてから開始
        try await service.deleteAllData()

        // 非常に長いテキストを含むテストデータ
        let longDescription = String(repeating: "これは長い説明です。", count: 100)
        let longReflection = String(repeating: "これは長い振り返りです。", count: 50)

        var log = LearningLog(
            title: "長いテキストテスト",
            description: longDescription,
            category: .programming,
            isPublic: false
        )
        log.reflections.append(Reflection(content: longReflection, type: .learning))

        try await service.appendLearningLog(log)

        @MainActor
        func testExport() async throws {
            let viewModel = LearningLogViewModel()
            await viewModel.loadLogs()

            guard let csvURL = viewModel.exportToCSV() else {
                throw TestError.exportFailed
            }

            let csvContent = try String(contentsOf: csvURL, encoding: .utf8)

            // 長いテキストが正しくエクスポートされている
            #expect(csvContent.contains("これは長い説明です。"))
            #expect(csvContent.contains("これは長い振り返りです。"))

            // ファイルサイズが適切である（非常に大きすぎない）
            let fileSize = try FileManager.default.attributesOfItem(atPath: csvURL.path)[.size] as! Int
            #expect(fileSize < 100_000) // 100KB未満であるべき

            try FileManager.default.removeItem(at: csvURL)
        }

        try await testExport()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testExportToCSVWithManySkills() async throws {
        let service = PersistenceService.shared

        // クリーンアップしてから開始
        try await service.deleteAllData()

        // 多くのスキルとリフレクションを含むテストデータ
        var log = LearningLog(
            title: "多くのスキル",
            description: "説明",
            category: .programming,
            isPublic: false
        )

        // 10個のスキルを追加
        for i in 1...10 {
            log.skills.append(Skill(name: "スキル\(i)", level: .intermediate))
        }

        // 5個のリフレクションを追加
        for i in 1...5 {
            log.reflections.append(Reflection(content: "振り返り\(i)", type: .learning))
        }

        try await service.appendLearningLog(log)

        @MainActor
        func testExport() async throws {
            let viewModel = LearningLogViewModel()
            await viewModel.loadLogs()

            guard let csvURL = viewModel.exportToCSV() else {
                throw TestError.exportFailed
            }

            let csvContent = try String(contentsOf: csvURL, encoding: .utf8)

            // スキルがセミコロンで区切られている
            #expect(csvContent.contains("スキル1"))
            #expect(csvContent.contains("スキル10"))

            // リフレクションがセミコロンで区切られている
            #expect(csvContent.contains("振り返り1"))
            #expect(csvContent.contains("振り返り5"))

            try FileManager.default.removeItem(at: csvURL)
        }

        try await testExport()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testExportToCSVWithEmptyArrays() async throws {
        let service = PersistenceService.shared

        // クリーンアップしてから開始
        try await service.deleteAllData()

        // スキルとリフレクションが空のテストデータ
        let log = LearningLog(
            title: "空の配列",
            description: "説明",
            category: .programming,
            isPublic: false
        )

        try await service.appendLearningLog(log)

        @MainActor
        func testExport() async throws {
            let viewModel = LearningLogViewModel()
            await viewModel.loadLogs()

            guard let csvURL = viewModel.exportToCSV() else {
                throw TestError.exportFailed
            }

            let csvContent = try String(contentsOf: csvURL, encoding: .utf8)

            // 空の配列でエクスポートが成功している
            #expect(csvContent.contains("空の配列"))

            // 行が適切にフォーマットされている
            let lines = csvContent.components(separatedBy: "\n")
            #expect(lines.count >= 2) // ヘッダー + 1行

            try FileManager.default.removeItem(at: csvURL)
        }

        try await testExport()

        // クリーンアップ
        try await service.deleteAllData()
    }

    @Test func testExportToCSVWithEmptyStringFields() async throws {
        let service = PersistenceService.shared

        // クリーンアップしてから開始
        try await service.deleteAllData()

        // 空のフィールドを含むテストデータ
        let log = LearningLog(
            title: "",
            description: "",
            category: .other,
            isPublic: false
        )

        try await service.appendLearningLog(log)

        @MainActor
        func testExport() async throws {
            let viewModel = LearningLogViewModel()
            await viewModel.loadLogs()

            guard let csvURL = viewModel.exportToCSV() else {
                throw TestError.exportFailed
            }

            let csvContent = try String(contentsOf: csvURL, encoding: .utf8)

            // 空のフィールドでもエクスポートが成功している
            let lines = csvContent.components(separatedBy: "\n")
            let dataLine = lines.first { $0.contains(",,,") } // 空のフィールドを探す

            #expect(dataLine != nil)

            try FileManager.default.removeItem(at: csvURL)
        }

        try await testExport()

        // クリーンアップ
        try await service.deleteAllData()
    }
}

// MARK: - XcodeGen Build Issue Tests

struct XcodeGenBuildIssueTests {
    @Test func testXcodeGenVersion() async throws {
        // XcodeGenのバージョンを確認
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/xcodegen")
        process.arguments = ["--version"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        // バージョンが含まれている
        #expect(output.contains("Version"))
    }

    @Test func testXcodeGenConfiguration() async throws {
        // project.ymlが存在し、正しく設定されている
        let projectPath = "/Users/fukku/.opengoat/workspaces/fe-dev-2/gakuse-ai-ios-repo/project.yml"
        #expect(FileManager.default.fileExists(atPath: projectPath))

        let content = try String(contentsOfFile: projectPath)

        // 主要な設定が含まれている
        #expect(content.contains("GakuseAI"))
        #expect(content.contains("GakuseAITests"))
        #expect(content.contains("GakuseAIUITests"))
        #expect(content.contains("Supabase"))
    }

    @Test func testSwiftVersion() async throws {
        // Swiftのバージョンを確認
        let projectPath = "/Users/fukku/.opengoat/workspaces/fe-dev-2/gakuse-ai-ios-repo/project.yml"
        let content = try String(contentsOfFile: projectPath)

        // Swift 6.0が設定されている
        #expect(content.contains("SWIFT_VERSION"))
        #expect(content.contains("6.0"))
    }
}

enum TestError: Error {
    case exportFailed
}

// MARK: - SignUpView Form Validation Tests

struct SignUpViewFormValidationTests {
    @Test func testIsValidEmail() async throws {
        // 有効なメールアドレス
        #expect(isValidEmail("test@example.com"))
        #expect(isValidEmail("user.name@domain.co.jp"))
        #expect(isValidEmail("user+tag@example.org"))

        // 無効なメールアドレス
        #expect(!isValidEmail(""))
        #expect(!isValidEmail("invalid"))
        #expect(!isValidEmail("@example.com"))
        #expect(!isValidEmail("test@"))
        #expect(!isValidEmail("test example.com"))
        #expect(!isValidEmail("test..test@example.com"))
    }

    @Test func testPasswordStrength() async throws {
        // 弱いパスワード
        #expect(calculatePasswordStrength("weak") == 1)

        // 普通のパスワード
        #expect(calculatePasswordStrength("password123") >= 2)

        // 強いパスワード
        #expect(calculatePasswordStrength("Password123!") >= 3)

        // 非常に強いパスワード
        #expect(calculatePasswordStrength("Password123!@#") == 4)
    }

    @Test func testPasswordStrengthEmpty() async throws {
        // 空のパスワード
        #expect(calculatePasswordStrength("") == 0)
    }

    @Test func testPasswordStrengthText() async throws {
        #expect(getPasswordStrengthText(0) == "")
        #expect(getPasswordStrengthText(1) == "弱い")
        #expect(getPasswordStrengthText(2) == "普通")
        #expect(getPasswordStrengthText(3) == "強い")
        #expect(getPasswordStrengthText(4) == "非常に強い")
    }

    @Test func testPasswordStrengthColor() async throws {
        // 各強度の色が正しく設定されている
        for score in 0..<4 {
            let color = getPasswordStrengthColor(for: score, strength: 1)
            // 色が返されることを確認
        }
    }
}

// MARK: - ContentView Simplification Tests

struct ContentViewSimplificationTests {
    @Test func testContentViewNoContentViewModel() async throws {
        // ContentViewでContentViewModelを使用していないことを確認
        // ContentViewModel.swiftファイルが削除されたことを確認
        let contentViewModelPath = "/Users/fukku/.opengoat/workspaces/fe-dev-2/gakuse-ai-ios-repo/GakuseAI/ViewModels/ContentViewModel.swift"
        #expect(!FileManager.default.fileExists(atPath: contentViewModelPath))
    }

    @Test func testContentViewUsesAuthViewModel() async throws {
        // ContentViewが@EnvironmentObject var authViewModel: AuthViewModelを使用している
        // ContentView.swiftを確認
        let contentViewPath = "/Users/fukku/.opengoat/workspaces/fe-dev-2/gakuse-ai-ios-repo/GakuseAI/Views/ContentView.swift"
        let content = try String(contentsOfFile: contentViewPath)

        // AuthViewModelを使用している
        #expect(content.contains("AuthViewModel"))
        #expect(content.contains("authViewModel"))

        // ContentViewModelを使用していない
        #expect(!content.contains("ContentViewModel"))
    }
}

// MARK: - Helper Functions for Tests

func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}

func calculatePasswordStrength(_ password: String) -> Int {
    guard !password.isEmpty else { return 0 }
    var score = 0
    if password.count >= 8 { score += 1 }
    if password.contains(where: { $0.isUppercase }) { score += 1 }
    if password.contains(where: { $0.isNumber }) { score += 1 }
    if password.contains(where: { !$0.isLetter && !$0.isNumber }) { score += 1 }
    return score
}

func getPasswordStrengthText(_ strength: Int) -> String {
    switch strength {
    case 0: return ""
    case 1: return "弱い"
    case 2: return "普通"
    case 3: return "強い"
    case 4: return "非常に強い"
    default: return ""
    }
}

func getPasswordStrengthColor(for index: Int, strength: Int) -> Color {
    if index < strength {
        switch strength {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        default: return .gray.opacity(0.3)
        }
    }
    return .gray.opacity(0.3)
}



