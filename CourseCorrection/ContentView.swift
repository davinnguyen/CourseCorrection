import SwiftUI

struct ContentView: View {
    @StateObject private var schoolStore = SchoolStore()
    @StateObject private var instructorStore = InstructorStore()
    @StateObject private var departmentStore = DepartmentStore()

    var body: some View {
        TabView {
            SchoolsView()
                .tabItem {
                    Label("Schools", systemImage: "building.columns")
                }
                .environmentObject(schoolStore)
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
        }
    }
}

#Preview {
    ContentView()
}
