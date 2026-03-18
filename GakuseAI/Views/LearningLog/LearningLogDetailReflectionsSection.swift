import SwiftUI

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
