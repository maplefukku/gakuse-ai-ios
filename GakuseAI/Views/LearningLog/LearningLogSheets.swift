import SwiftUI

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
