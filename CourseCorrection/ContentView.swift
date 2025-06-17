import SwiftUI

struct ContentView: View {
    @StateObject private var store = SchoolStore()
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach($store.schools) { $school in
                    NavigationLink(school.name) {
                        SchoolFormView(school: $school)
                            .navigationTitle("Edit School")
                    }
                }
            }
            .navigationTitle("Schools")
            .toolbar {
                Button("Add") { showingAdd = true }
            }
            .sheet(isPresented: $showingAdd) {
                AddSchoolSheet()
                    .environmentObject(store)
            }
        }
    }
}

struct AddSchoolSheet: View {
    @EnvironmentObject var store: SchoolStore
    @Environment(\.dismiss) var dismiss
    @State private var newSchool = School(name: "", location: "", type: .university)

    var body: some View {
        NavigationStack {
            SchoolFormView(school: $newSchool)
                .navigationTitle("New School")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.schools.append(newSchool)
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { dismiss() }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
