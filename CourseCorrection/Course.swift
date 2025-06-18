import Foundation

struct Course: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var subjectID: UUID
    var courseNumber: String
    var title: String
    var description: String
    var units: Int
}
