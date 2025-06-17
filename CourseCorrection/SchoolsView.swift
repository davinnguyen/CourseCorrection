import SwiftUI

struct SchoolsView: View {
    @EnvironmentObject var store: SchoolStore
    @State private var showingAdd = false
    @State private var searchText = ""

    private var sortedSchools: [School] {
        store.schools.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var filteredSchools: [School] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return sortedSchools
        }
        return sortedSchools.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredSchools) { school in
                    if let _ = store.schools.firstIndex(where: { $0.id == school.id }) {
                        NavigationLink(school.name) {
                            EditSchoolView(school: school)
                                .environmentObject(store)
                        }
                    }
                }
                .onDelete(perform: deleteSchools)
            }
            .overlay {
                if sortedSchools.isEmpty {
                    ContentUnavailableView("No Schools", systemImage: "building.columns")
                }
            }
            .navigationTitle("Schools")
            .toolbar {
                Button("Add") { showingAdd = true }
            }
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddSchoolSheet()
                    .environmentObject(store)
            }
        }
    }

    private func deleteSchools(at offsets: IndexSet) {
        let ids = offsets.map { filteredSchools[$0].id }
        store.remove(ids: ids)
    }
}

struct AddSchoolSheet: View {
    @EnvironmentObject var store: SchoolStore
    @Environment(\.dismiss) var dismiss
    @State private var newSchool = School(name: "", location: "", type: .university)

    var body: some View {
        NavigationStack {
            Form {
                SchoolFormView(school: $newSchool)
            }
                .navigationTitle("New School")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.add(newSchool)
                            dismiss()
                        }
                        .disabled(newSchool.name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { dismiss() }
                    }
                }
        }
    }
}

struct EditSchoolView: View {
    @EnvironmentObject var store: SchoolStore
    @Environment(\.dismiss) var dismiss

    @State private var editedSchool: School
    private let originalSchool: School

    init(school: School) {
        self._editedSchool = State(initialValue: school)
        self.originalSchool = school
    }

    var body: some View {
        Form {
            SchoolFormView(school: $editedSchool)
        }
        .navigationTitle("Edit School")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(editedSchool == originalSchool)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
    }

    private func save() {
        if let index = store.schools.firstIndex(where: { $0.id == originalSchool.id }) {
            store.schools[index] = editedSchool
            store.save()
        }
        dismiss()
    }
}

#Preview {
    SchoolsView().environmentObject(SchoolStore())
}
