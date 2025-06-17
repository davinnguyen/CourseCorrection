import Foundation

struct Department: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var name: String
    var schoolID: UUID
}
