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
