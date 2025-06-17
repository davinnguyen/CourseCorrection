import SwiftUI

struct DepartmentsView: View {
    @EnvironmentObject var store: DepartmentStore
    @EnvironmentObject var schoolStore: SchoolStore
    @State private var showingAdd = false
    @State private var searchText = ""

    private var sortedDepartments: [Department] {
        store.departments.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var filteredDepartments: [Department] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return sortedDepartments
        }
        return sortedDepartments.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var sortedSchools: [School] {
        schoolStore.schools.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func departments(for school: School) -> [Department] {
        filteredDepartments.filter { $0.schoolID == school.id }
    }

    private var unknownDepartments: [Department] {
        filteredDepartments.filter { dept in
            !schoolStore.schools.contains(where: { $0.id == dept.schoolID })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedSchools) { school in
                    if !departments(for: school).isEmpty {
                        Section(header: Text(school.name)) {
                            ForEach(departments(for: school)) { department in
                                if let index = store.departments.firstIndex(where: { $0.id == department.id }) {
                                    NavigationLink(department.name) {
                                        DepartmentFormView(department: $store.departments[index])
                                            .environmentObject(schoolStore)
                                            .navigationTitle("Edit Department")
                                    }
                                }
                            }
                            .onDelete { offsets in
                                deleteDepartments(at: offsets, in: departments(for: school))
                            }
                        }
                    }
                }

                if !unknownDepartments.isEmpty {
                    Section(header: Text("Unknown School")) {
                        ForEach(unknownDepartments) { department in
                            if let index = store.departments.firstIndex(where: { $0.id == department.id }) {
                                NavigationLink(department.name) {
                                    DepartmentFormView(department: $store.departments[index])
                                        .environmentObject(schoolStore)
                                        .navigationTitle("Edit Department")
                                }
                            }
                        }
                        .onDelete { offsets in
                            deleteDepartments(at: offsets, in: unknownDepartments)
                        }
                    }
                }
            }
            .overlay {
                if sortedDepartments.isEmpty {
                    ContentUnavailableView("No Departments", systemImage: "books.vertical")
                }
            }
            .navigationTitle("Departments")
            .toolbar {
                Button("Add") { showingAdd = true }
            }
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddDepartmentSheet()
                    .environmentObject(store)
                    .environmentObject(schoolStore)
            }
        }
    }

    private func deleteDepartments(at offsets: IndexSet, in list: [Department]) {
        for index in offsets {
            let id = list[index].id
            if let original = store.departments.firstIndex(where: { $0.id == id }) {
                store.departments.remove(at: original)
            }
        }
    }
}

struct AddDepartmentSheet: View {
    @EnvironmentObject var store: DepartmentStore
    @EnvironmentObject var schoolStore: SchoolStore
    @Environment(\.dismiss) var dismiss
    @State private var newDepartment = Department(name: "", schoolID: UUID())

    var body: some View {
        NavigationStack {
            Form {
                DepartmentFormView(department: $newDepartment)
                    .environmentObject(schoolStore)
            }
            .navigationTitle("New Department")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.departments.append(newDepartment)
                        dismiss()
                    }
                    .disabled(newDepartment.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    DepartmentsView()
        .environmentObject(DepartmentStore())
        .environmentObject(SchoolStore())
}
