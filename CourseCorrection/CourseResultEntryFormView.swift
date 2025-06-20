import SwiftUI

struct CourseResultEntryFormView: View {
    @EnvironmentObject var classItemStore: ClassItemStore
    @EnvironmentObject var courseStore: CourseStore
    @Binding var entry: CourseResultEntry

    private var classOptions: [ClassItem] { classItemStore.classItems }

    var body: some View {
        Group {
            Picker("Class", selection: $entry.classID) {
                ForEach(classOptions) { item in
                    if let course = courseStore.courses.first(where: { $0.id == item.courseID }) {
                        Text("\(course.courseNumber) - \(course.title)").tag(item.id)
                    }
                }
            }
            Picker("Result", selection: $entry.courseResult) {
                Text("None").tag(nil as CourseResult?)
                ForEach(CourseResult.allOptions, id: \.self) { result in
                    Text(result.description).tag(Optional(result))
                }
            }
        }
    }
}

#Preview {
    CourseResultEntryFormView(entry: .constant(CourseResultEntry(classID: UUID(), courseResult: nil)))
        .environmentObject(ClassItemStore())
        .environmentObject(CourseStore())
}
