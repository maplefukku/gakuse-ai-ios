import SwiftUI

struct LearningLogView: View {
    @StateObject private var viewModel = LearningLogViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.logs.isEmpty {
                    ProgressView("読み込み中...")
                } else if viewModel.logs.isEmpty {
                    emptyStateView
                } else {
                    logListView
                }
            }
            .navigationTitle("学習ログ")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateSheet) {
                CreateLearningLogView { title, description, category, isPublic in
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
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "ログがありません",
            systemImage: "book.closed",
            description: Text("右下のボタンから学習ログを作成しましょう")
        )
    }
    
    private var logListView: some View {
        List {
            ForEach(viewModel.logs) { log in
                NavigationLink(value: log) {
                    LearningLogRow(log: log)
                }
            }
            .onDelete { offsets in
                Task {
                    await viewModel.deleteLog(at: offsets)
                }
            }
        }
        .navigationDestination(for: LearningLog.self) { log in
            LearningLogDetailView(log: log, viewModel: viewModel)
        }
    }
}

// MARK: - Learning Log Row

struct LearningLogRow: View {
    let log: LearningLog
    
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
    
    let onCreate: (String, String, LearningCategory, Bool) -> Void
    
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
            .navigationTitle("新しいログ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("作成") {
                        onCreate(title, description, category, isPublic)
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
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
                        Task {
                            await viewModel.togglePublic(for: currentLog)
                        }
                    } label: {
                        Label(
                            currentLog.isPublic ? "非公開にする" : "公開する",
                            systemImage: currentLog.isPublic ? "lock" : "globe"
                        )
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
                ForEach(currentLog.skills) { skill in
                    HStack {
                        Text(skill.name)
                        Spacer()
                        Text(skill.level.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(8)
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
                ForEach(currentLog.reflections) { reflection in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(reflection.type.rawValue)
                            .font(.caption)
                            .foregroundColor(.pink)
                        Text(reflection.content)
                            .font(.body)
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
