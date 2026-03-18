//
//  SkillProgressRow.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-17.
//

import SwiftUI

/// スキル進捗行
struct SkillProgressRow: View {
    let skill: SkillData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(skill.name)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(skill.count)")
                    .font(.body.bold())
                    .foregroundColor(.primary)
            }

            ProgressView(value: skill.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        SkillProgressRow(skill: SkillData(
            name: "Swift",
            count: 24,
            progress: 0.8
        ))

        SkillProgressRow(skill: SkillData(
            name: "Python",
            count: 18,
            progress: 0.6
        ))
    }
    .padding()
}
