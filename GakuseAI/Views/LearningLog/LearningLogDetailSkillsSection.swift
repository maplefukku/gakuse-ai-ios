import SwiftUI

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
