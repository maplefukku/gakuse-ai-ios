import Foundation

struct LearningLog: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: LearningCategory
    let createdAt: Date
    let updatedAt: Date
    var skills: [Skill]
    var reflections: [Reflection]
    var isPublic: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: LearningCategory,
        isPublic: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
        self.skills = []
        self.reflections = []
        self.isPublic = isPublic
    }
}

enum LearningCategory: String, Codable, CaseIterable {
    case programming = "プログラミング"
    case design = "デザイン"
    case business = "ビジネス"
    case language = "語学"
    case creative = "クリエイティブ"
    case other = "その他"
    
    var icon: String {
        switch self {
        case .programming: return "chevron.left.forwardslash.chevron.right"
        case .design: return "paintbrush.fill"
        case .business: return "briefcase.fill"
        case .language: return "globe"
        case .creative: return "sparkles"
        case .other: return "star.fill"
        }
    }
}

struct Skill: Identifiable, Codable {
    let id: UUID
    let name: String
    let level: SkillLevel
    
    init(name: String, level: SkillLevel = .beginner) {
        self.id = UUID()
        self.name = name
        self.level = level
    }
}

enum SkillLevel: String, Codable {
    case beginner = "初級"
    case intermediate = "中級"
    case advanced = "上級"
    case expert = "エキスパート"
}

struct Reflection: Identifiable, Codable {
    let id: UUID
    let content: String
    let createdAt: Date
    let type: ReflectionType
    
    init(content: String, type: ReflectionType) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.type = type
    }
}

enum ReflectionType: String, Codable {
    case learning = "学んだこと"
    case challenge = "課題"
    case nextStep = "次のステップ"
    case insight = "気づき"
}
