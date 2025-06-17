import Foundation
import SwiftUI

enum SchoolType: String, CaseIterable, Identifiable, Codable {
    case university = "University"
    case communityCollege = "Community College"

    var id: String { rawValue }
}

struct School: Identifiable, Codable {
    var id = UUID()
    var name: String
    var location: String
    var type: SchoolType
}
