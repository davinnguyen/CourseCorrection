import SwiftUI

struct ContentView: View {
    @StateObject private var schoolStore = SchoolStore()
    @StateObject private var instructorStore = InstructorStore()
    @StateObject private var departmentStore = DepartmentStore()

    @StateObject private var semesterStore = SemesterStore()
    @StateObject private var subjectStore = SubjectStore()
    @StateObject private var courseStore = CourseStore()
    @StateObject private var classItemStore = ClassItemStore()
    @StateObject private var courseResultEntryStore = CourseResultEntryStore()

    var body: some View {
        TabView {
            SchoolsView()
                .tabItem {
                    Label("Schools", systemImage: "building.columns")
                }
                .environmentObject(schoolStore)
                .environmentObject(semesterStore)
            InstructorsView()
                .tabItem {
                    Label("Instructors", systemImage: "person.2")
                }
                .environmentObject(instructorStore)
                .environmentObject(departmentStore)
            DepartmentsView()
                .tabItem {
                    Label("Departments", systemImage: "books.vertical")
                }
                .environmentObject(departmentStore)
                .environmentObject(schoolStore)
            SubjectsView()
                .tabItem {
                    Label("Subjects", systemImage: "book")
                }
                .environmentObject(subjectStore)
                .environmentObject(schoolStore)
            CoursesView()
                .tabItem {
                    Label("Courses", systemImage: "book.closed")
                }
                .environmentObject(courseStore)
                .environmentObject(subjectStore)
            ClassItemsView()
                .tabItem {
                    Label("Classes", systemImage: "calendar")
                }
                .environmentObject(classItemStore)
                .environmentObject(courseStore)
                .environmentObject(instructorStore)
                .environmentObject(semesterStore)
            CourseResultEntriesView()
                .tabItem {
                    Label("Results", systemImage: "chart.bar")
                }
                .environmentObject(courseResultEntryStore)
                .environmentObject(classItemStore)
                .environmentObject(courseStore)
                .environmentObject(semesterStore)
        }
        .overlay(alignment: .bottom) {
            Text(departmentStore.usingICloud ? "Stored in iCloud" : "Stored on Device")
                .font(.footnote)
                .padding(6)
                .background(.thinMaterial)
                .cornerRadius(8)
                .padding(.bottom, 4)
        }
    }
}

#Preview {
    ContentView()
}
