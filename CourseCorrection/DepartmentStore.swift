import Foundation

class DepartmentStore: ObservableObject {
    @Published var departments: [Department] = []
}
