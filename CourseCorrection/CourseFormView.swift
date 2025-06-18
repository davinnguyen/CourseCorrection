import SwiftUI

struct CourseFormView: View {
    @EnvironmentObject var subjectStore: SubjectStore
    @Binding var course: Course

    var body: some View {
        Group {
            Picker("Subject", selection: $course.subjectID) {
                ForEach(subjectStore.subjects) { subject in
                    Text(subject.name).tag(subject.id)
                }
            }
            TextField("Course Number", text: $course.courseNumber)
            TextField("Title", text: $course.title)
            TextField("Description", text: $course.description)
            Stepper(value: $course.units, in: 0...20) {
                Text("Units: \(course.units)")
            }
        }
    }
}

#Preview {
    CourseFormView(course: .constant(Course(subjectID: UUID(), courseNumber: "101", title: "Example", description: "", units: 3)))
        .environmentObject(SubjectStore())
}
