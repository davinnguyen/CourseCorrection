import Foundation

struct Semester: Identifiable, Equatable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var schoolID: UUID
    var startDate: DateComponents
    var endDate: DateComponents
}
