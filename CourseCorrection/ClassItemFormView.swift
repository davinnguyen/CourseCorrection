import SwiftUI

struct ClassItemFormView: View {
    @EnvironmentObject var courseStore: CourseStore
    @EnvironmentObject var instructorStore: InstructorStore
    @EnvironmentObject var semesterStore: SemesterStore
    @Binding var classItem: ClassItem

    var body: some View {
        Group {
            Picker("Course", selection: $classItem.courseID) {
                ForEach(courseStore.courses) { course in
                    Text("\(course.courseNumber) - \(course.title)").tag(course.id)
                }
            }
            Picker("Semester", selection: $classItem.semesterID) {
                Text("None").tag(nil as UUID?)
                ForEach(semesterStore.semesters) { semester in
                    Text(semester.name).tag(Optional(semester.id))
                }
            }
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
        .environmentObject(SemesterStore())
}
