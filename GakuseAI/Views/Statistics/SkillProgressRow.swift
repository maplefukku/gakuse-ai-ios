//
//  SkillProgressRow.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

/// スキル進捗行
///
/// 統計画面のスキル分析セクションで使用する行コンポーネント
struct SkillProgressRow: View {
    let skill: SkillData

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(skill.name)
                    .font(.subheadline)

                Spacer()

                Text("\(skill.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: skill.progress)
                .tint(.pink)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(skill.name): \(skill.count)回")
        .accessibilityValue("\(Int(skill.progress * 100))%")
    }
}
