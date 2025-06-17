import SwiftUI

struct ContentView: View {
    @StateObject private var schoolStore = SchoolStore()
    @StateObject private var instructorStore = InstructorStore()

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
        }
    }
}

#Preview {
    ContentView()
}
