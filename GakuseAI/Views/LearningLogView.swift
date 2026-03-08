import SwiftUI

struct LearningLogView: View {
    @StateObject private var viewModel = LearningLogViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.logs.isEmpty {
                    ProgressView("読み込み中...")
                } else if viewModel.filteredLogs.isEmpty {
                    if viewModel.logs.isEmpty {
                        emptyStateView
                    } else {
                        noResultsView
                    }
                } else {
                    logListView
                }
            }
            .navigationTitle("学習ログ")
            .searchable(text: $viewModel.searchText, prompt: "ログを検索...")
            .accessibilityElement(children: .contain)
            .accessibilityLabel("学習ログ一覧")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        // ソート順
                        Menu {
                            ForEach(LogSortOrder.allCases, id: \.self) { order in
                                Button {
                                    viewModel.sortOrder = order
                                } label: {
                                    Label(order.rawValue, systemImage: viewModel.sortOrder == order ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Label("ソート順", systemImage: "arrow.up.arrow.down")
                        }

                        Divider()

                        // カテゴリフィルター
                        Menu {
                            Button {
                                viewModel.selectedCategory = nil
                            } label: {
                                Label("すべて", systemImage: viewModel.selectedCategory == nil ? "checkmark" : "")
                            }

                            Divider()

                            ForEach(LearningCategory.allCases, id: \.self) { category in
                                Button {
                                    viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                                } label: {
                                    Label(category.rawValue, systemImage: viewModel.selectedCategory == category ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Label("カテゴリ", systemImage: "line.3.horizontal.decrease.circle")
                        }

                        // 公開設定フィルター
                        Button {
                            viewModel.showOnlyPublic.toggle()
                        } label: {
                            Label("公開のみ", systemImage: viewModel.showOnlyPublic ? "checkmark" : "")
                        }

                        // お気に入りフィルター
                        Button {
                            viewModel.showingFavoritesOnly.toggle()
                        } label: {
                            Label("お気に入り", systemImage: viewModel.showingFavoritesOnly ? "star.fill" : "star")
                        }

                        Divider()

                        // 検索オプション
                        Button {
                            viewModel.showingSearchOptions = true
                        } label: {
                            Label("検索オプション", systemImage: "magnifyingglass.circle")
                        }

                        // エクスポート
                        Button {
                            viewModel.showingExportOptions = true
                        } label: {
                            Label("エクスポート", systemImage: "square.and.arrow.up")
                        }

                        Divider()

                        Button {
                            viewModel.showingCreateSheet = true
                        } label: {
                            Label("新規作成", systemImage: "plus.circle.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateSheet) {
                CreateLearningLogView(
                    existingLog: nil,
                    onSave: { title, description, category, isPublic in
                        Task {
                            await viewModel.createLog(
                                title: title,
                                description: description,
                                category: category,
                                isPublic: isPublic
                            )
                        }
                        viewModel.showingCreateSheet = false
                    }
                )
            }
            .sheet(item: $viewModel.logToEdit) { log in
                CreateLearningLogView(
                    existingLog: log,
                    onSave: { title, description, category, isPublic in
                        Task {
                            await viewModel.updateLog(
                                id: log.id,
                                title: title,
                                description: description,
                                category: category,
                                isPublic: isPublic
                            )
                        }
                        viewModel.logToEdit = nil
                    }
                )
            }
            .alert("エラー", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
        .refreshable {
            await viewModel.loadLogs()
        }
        .sheet(isPresented: $viewModel.showingSearchOptions) {
            SearchOptionsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingExportOptions) {
            ExportOptionsSheet(viewModel: viewModel)
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "ログがありません",
            systemImage: "book.closed",
            description: Text("右下のボタンから学習ログを作成しましょう")
        )
    }
    
    private var noResultsView: some View {
        ContentUnavailableView(
            "該当するログがありません",
            systemImage: "magnifyingglass",
            description: Text("検索条件を変更してみてください")
        )
    }
    
    private var logListView: some View {
        List {
            ForEach(viewModel.filteredLogs) { log in
                NavigationLink(value: log) {
                    LearningLogRow(log: log, viewModel: viewModel)
                }
            }
            .onDelete { offsets in
                // フィルター後の配列から削除対象を特定し、元の配列のインデックスを取得
                let logsToDelete = offsets.map { viewModel.filteredLogs[$0] }
                let indicesToDelete = logsToDelete.compactMap { log in
                    viewModel.logs.firstIndex(where: { $0.id == log.id })
                }

                Task {
                    await viewModel.deleteLog(at: IndexSet(indicesToDelete))
                }
            }
        }
        .navigationDestination(for: LearningLog.self) { log in
            LearningLogDetailView(log: log, viewModel: viewModel)
        }
        .sheet(item: $viewModel.logToEdit) { log in
            LearningLogDetailView(log: log, viewModel: viewModel)
        }
    }
}

// MARK: - Learning Log Row

struct LearningLogRow: View {
    let log: LearningLog
    let viewModel: LearningLogViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: log.category.icon)
                    .foregroundColor(.pink)
                Text(log.title)
                    .font(.headline)
                Spacer()
                if log.isPublic {
                    Image(systemName: "globe")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                Button {
                    Task {
                        await viewModel.toggleFavorite(for: log)
                    }
                } label: {
                    Image(systemName: log.isFavorite ? "star.fill" : "star")
                        .foregroundColor(log.isFavorite ? .yellow : .gray)
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            Text(log.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(log.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pink.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(log.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Create Learning Log View

struct CreateLearningLogView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var category: LearningCategory = .programming
    @State private var isPublic = false
    
    let existingLog: LearningLog?
    let onSave: (String, String, LearningCategory, Bool) -> Void
    
    private var isEditMode: Bool {
        existingLog != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("タイトル", text: $title, prompt: Text("何を学びましたか？"))
                    TextField("学習内容の詳細を入力...", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("カテゴリ") {
                    Picker("カテゴリ", selection: $category) {
                        ForEach(LearningCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section {
                    Toggle("公開する", isOn: $isPublic)
                    Text("公開するとポートフォリオに表示されます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(isEditMode ? "ログ編集" : "新しいログ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditMode ? "更新" : "作成") {
                        onSave(title, description, category, isPublic)
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
        .onAppear {
            if let log = existingLog {
                title = log.title
                description = log.description
                category = log.category
                isPublic = log.isPublic
            }
        }
    }
}

// MARK: - Learning Log Detail View

struct LearningLogDetailView: View {
    let log: LearningLog
    @ObservedObject var viewModel: LearningLogViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddSkill = false
    @State private var showingAddReflection = false
    @State private var newSkillName = ""
    @State private var newSkillLevel: SkillLevel = .beginner
    @State private var newReflectionContent = ""
    @State private var newReflectionType: ReflectionType = .learning
    @State private var showingDeleteConfirmation = false
    
    private var currentLog: LearningLog {
        viewModel.logs.first(where: { $0.id == log.id }) ?? log
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                // Description
                descriptionSection
                
                // Skills
                skillsSection
                
                // Reflections
                reflectionsSection
            }
            .padding()
        }
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        viewModel.editLog(currentLog)
                    } label: {
                        Label("編集", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button {
                        Task {
                            await viewModel.togglePublic(for: currentLog)
                        }
                    } label: {
                        Label(
                            currentLog.isPublic ? "非公開にする" : "公開する",
                            systemImage: currentLog.isPublic ? "lock" : "globe"
                        )
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddSkill) {
            AddSkillSheet(
                skillName: $newSkillName,
                skillLevel: $newSkillLevel,
                onAdd: {
                    Task {
                        await viewModel.addSkill(
                            to: currentLog,
                            name: newSkillName,
                            level: newSkillLevel
                        )
                        newSkillName = ""
                        newSkillLevel = .beginner
                        showingAddSkill = false
                    }
                }
            )
        }
        .sheet(isPresented: $showingAddReflection) {
            AddReflectionSheet(
                content: $newReflectionContent,
                type: $newReflectionType,
                onAdd: {
                    Task {
                        await viewModel.addReflection(
                            to: currentLog,
                            content: newReflectionContent,
                            type: newReflectionType
                        )
                        newReflectionContent = ""
                        newReflectionType = .learning
                        showingAddReflection = false
                    }
                }
            )
        }
        .alert("削除の確認", isPresented: $showingDeleteConfirmation) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                Task {
                    await viewModel.deleteLog(currentLog)
                    dismiss()
                }
            }
        } message: {
            Text("この学習ログを削除しますか？この操作は取り消せません。")
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: currentLog.category.icon)
                    .foregroundColor(.pink)
                Text(currentLog.category.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pink.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                if currentLog.isPublic {
                    Label("公開中", systemImage: "globe")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Text(currentLog.title)
                .font(.title.bold())
            
            Text(currentLog.createdAt.formatted(date: .long, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("説明")
                .font(.headline)
            Text(currentLog.description)
                .font(.body)
        }
        .padding()
    }
    
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("スキル")
                    .font(.headline)
                Spacer()
                Button {
                    showingAddSkill = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.pink)
                }
            }
            
            if currentLog.skills.isEmpty {
                Text("スキルを追加しましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                ForEach(Array(currentLog.skills.enumerated()), id: \.element.id) { index, skill in
                    HStack {
                        Text(skill.name)
                        Spacer()
                        Text(skill.level.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(8)
                        Button {
                            Task {
                                await viewModel.removeSkill(at: IndexSet(integer: index), from: currentLog)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }
    
    private var reflectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("振り返り")
                    .font(.headline)
                Spacer()
                Button {
                    showingAddReflection = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.pink)
                }
            }
            
            if currentLog.reflections.isEmpty {
                Text("振り返りを追加しましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                ForEach(Array(currentLog.reflections.enumerated()), id: \.element.id) { index, reflection in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reflection.type.rawValue)
                                .font(.caption)
                                .foregroundColor(.pink)
                            Text(reflection.content)
                                .font(.body)
                        }
                        Spacer()
                        Button {
                            Task {
                                await viewModel.removeReflection(at: IndexSet(integer: index), from: currentLog)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

// MARK: - Add Skill Sheet

struct AddSkillSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var skillName: String
    @Binding var skillLevel: SkillLevel
    let onAdd: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("スキル名") {
                    TextField("例: SwiftUI", text: $skillName)
                }
                
                Section("レベル") {
                    Picker("レベル", selection: $skillLevel) {
                        ForEach([SkillLevel.beginner, .intermediate, .advanced, .expert], id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("スキル追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        onAdd()
                    }
                    .disabled(skillName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Reflection Sheet

struct AddReflectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var content: String
    @Binding var type: ReflectionType
    let onAdd: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("タイプ") {
                    Picker("タイプ", selection: $type) {
                        ForEach([ReflectionType.learning, .challenge, .nextStep, .insight], id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("内容") {
                    TextField("振り返りを入力...", text: $content, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("振り返り追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        onAdd()
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }
}

#Preview {
    LearningLogView()
}

// MARK: - Search Options Sheet

struct SearchOptionsSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: LearningLogViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("日付範囲") {
                    DatePicker("開始日", selection: Binding(
                        get: { viewModel.dateRangeStart ?? Date() },
                        set: { viewModel.dateRangeStart = $0 }
                    ), displayedComponents: .date)
                    DatePicker("終了日", selection: Binding(
                        get: { viewModel.dateRangeEnd ?? Date() },
                        set: { viewModel.dateRangeEnd = $0 }
                    ), displayedComponents: .date)
                }

                Section("検索対象") {
                    Toggle("スキルも検索", isOn: $viewModel.searchInSkills)
                }

                Section {
                    Button("検索オプションをリセット") {
                        viewModel.resetSearchOptions()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("検索オプション")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Export Options Sheet

struct ExportOptionsSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: LearningLogViewModel
    @State private var showingShareSheet = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            List {
                Section("エクスポート形式") {
                    Button {
                        exportToCSV()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                            VStack(alignment: .leading) {
                                Text("CSV形式")
                                    .font(.headline)
                                Text("スプレッドシートで開ける形式")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Button {
                        exportToJSON()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                            VStack(alignment: .leading) {
                                Text("JSON形式")
                                    .font(.headline)
                                Text("データ形式でエクスポート")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section("エクスポート対象") {
                    Text("\(viewModel.filteredLogs.count) 件の学習ログ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("エクスポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ActivityViewController(activityItems: [url])
            }
        }
    }

    private func exportToCSV() {
        if let url = viewModel.exportToCSV() {
            exportURL = url
            showingShareSheet = true
        }
    }

    private func exportToJSON() {
        if let url = viewModel.exportToJSON() {
            exportURL = url
            showingShareSheet = true
        }
    }
}

// MARK: - Activity View Controller

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
