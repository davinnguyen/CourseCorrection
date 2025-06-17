import Foundation
import SwiftUI

class SchoolStore: ObservableObject {
    @Published var schools: [School] = []

    func add(_ school: School) {
        schools.append(school)
    }
}
