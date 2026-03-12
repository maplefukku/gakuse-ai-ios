import SwiftUI

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
                LearningLogDetailHeaderSection(log: currentLog)
                
                // Description
                LearningLogDetailDescriptionSection(log: currentLog)
                
                // Skills
                LearningLogDetailSkillsSection(
                    log: currentLog,
                    viewModel: viewModel,
                    showingAddSkill: $showingAddSkill
                )
                
                // Reflections
                LearningLogDetailReflectionsSection(
                    log: currentLog,
                    viewModel: viewModel,
                    showingAddReflection: $showingAddReflection
                )
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
}

// MARK: - Learning Log Detail Header Section

struct LearningLogDetailHeaderSection: View {
    let log: LearningLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: log.category.icon)
                    .foregroundColor(.pink)
                Text(log.category.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pink.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                if log.isPublic {
                    Label("公開中", systemImage: "globe")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Text(log.title)
                .font(.title.bold())
            
            Text(log.createdAt.formatted(date: .long, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Learning Log Detail Description Section

struct LearningLogDetailDescriptionSection: View {
    let log: LearningLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("説明")
                .font(.headline)
            Text(log.description)
                .font(.body)
        }
        .padding()
    }
}

// MARK: - Learning Log Detail Skills Section

struct LearningLogDetailSkillsSection: View {
    let log: LearningLog
    @ObservedObject var viewModel: LearningLogViewModel
    @Binding var showingAddSkill: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("スキル")
                    .font(.headline)
                Spacer()
                SkillAddButton {
                    showingAddSkill = true
                }
            }
            
            if log.skills.isEmpty {
                Text("スキルを追加しましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                ForEach(Array(log.skills.enumerated()), id: \.element.id) { index, skill in
                    HStack {
                        Text(skill.name)
                        Spacer()
                        Text(skill.level.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(8)
                        DeleteButton {
                            Task {
                                await viewModel.removeSkill(at: IndexSet(integer: index), from: log)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                }
            }
        }
        .padding()
    }
}

// MARK: - Learning Log Detail Reflections Section

struct LearningLogDetailReflectionsSection: View {
    let log: LearningLog
    @ObservedObject var viewModel: LearningLogViewModel
    @Binding var showingAddReflection: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("振り返り")
                    .font(.headline)
                Spacer()
                SkillAddButton {
                    showingAddReflection = true
                }
            }
            
            if log.reflections.isEmpty {
                Text("振り返りを追加しましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                ForEach(Array(log.reflections.enumerated()), id: \.element.id) { index, reflection in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reflection.type.rawValue)
                                .font(.caption)
                                .foregroundColor(.pink)
                            Text(reflection.content)
                                .font(.body)
                        }
                        Spacer()
                        DeleteButton {
                            Task {
                                await viewModel.removeReflection(at: IndexSet(integer: index), from: log)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                }
            }
        }
        .padding()
    }
}
