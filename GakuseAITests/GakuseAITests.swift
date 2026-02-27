import Testing
@testable import GakuseAI

struct GakuseAITests {
    @Test func testLearningLogCreation() async throws {
        let log = LearningLog(
            title: "テストログ",
            description: "これはテストです",
            category: .programming
        )
        
        #expect(log.title == "テストログ")
        #expect(log.description == "これはテストです")
        #expect(log.category == .programming)
        #expect(log.isPublic == false)
        #expect(log.skills.isEmpty)
        #expect(log.reflections.isEmpty)
    }
    
    @Test func testSkillCreation() async throws {
        let skill = Skill(name: "Swift", level: .intermediate)
        
        #expect(skill.name == "Swift")
        #expect(skill.level == .intermediate)
    }
    
    @Test func testReflectionCreation() async throws {
        let reflection = Reflection(
            content: "学んだことのテスト",
            type: .learning
        )
        
        #expect(reflection.content == "学んだことのテスト")
        #expect(reflection.type == .learning)
    }
}
