import Foundation

class SchoolStore: ObservableObject {
    @Published var schools: [School] = []
}
