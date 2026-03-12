import SwiftUI

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
