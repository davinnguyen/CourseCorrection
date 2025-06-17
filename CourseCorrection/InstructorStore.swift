import Foundation

class InstructorStore: ObservableObject {
    @Published var instructors: [Instructor] = []
}
