import SwiftUI

struct ClassItemFormView: View {
    @EnvironmentObject var courseStore: CourseStore
    @EnvironmentObject var instructorStore: InstructorStore
    @Binding var classItem: ClassItem

    @State private var semesterIDText: String = ""

    var body: some View {
        Group {
            Picker("Course", selection: $classItem.courseID) {
                ForEach(courseStore.courses) { course in
                    Text("\(course.courseNumber) - \(course.title)").tag(course.id)
                }
            }
            TextField("Semester ID", text: Binding(
                get: { classItem.semesterID?.uuidString ?? "" },
                set: { classItem.semesterID = UUID(uuidString: $0) }
            ))
            Picker("Instructor", selection: $classItem.instructorID) {
                Text("None").tag(nil as UUID?)
                ForEach(instructorStore.instructors) { instructor in
                    Text(instructor.name).tag(Optional(instructor.id))
                }
            }
        }
    }
}

#Preview {
    ClassItemFormView(classItem: .constant(ClassItem(courseID: UUID(), semesterID: nil, instructorID: nil)))
        .environmentObject(CourseStore())
        .environmentObject(InstructorStore())
}
