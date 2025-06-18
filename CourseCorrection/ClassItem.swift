import Foundation

struct ClassItem: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var courseID: UUID
    var semesterID: UUID?
    var instructorID: UUID?
}
