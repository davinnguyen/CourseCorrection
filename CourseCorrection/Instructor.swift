import Foundation
import SwiftUI

struct Instructor: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var name: String
    var departments: Set<UUID>
}
