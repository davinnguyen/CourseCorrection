import SwiftUI

struct DepartmentsView: View {
    @EnvironmentObject var store: DepartmentStore
    @EnvironmentObject var schoolStore: SchoolStore
    @State private var showingAdd = false

    private var sortedDepartments: [Department] {
        store.departments.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedDepartments) { department in
                    if let index = store.departments.firstIndex(where: { $0.id == department.id }) {
                        NavigationLink(department.name) {
                            DepartmentFormView(department: $store.departments[index])
                                .environmentObject(schoolStore)
                                .navigationTitle("Edit Department")
                        }
                    }
                }
                .onDelete(perform: deleteDepartments)
            }
            .navigationTitle("Departments")
            .toolbar {
                Button("Add") { showingAdd = true }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddDepartmentSheet()
                    .environmentObject(store)
                    .environmentObject(schoolStore)
            }
        }
    }

    private func deleteDepartments(at offsets: IndexSet) {
        for index in offsets {
            let id = sortedDepartments[index].id
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
