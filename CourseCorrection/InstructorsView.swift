import SwiftUI

struct InstructorsView: View {
    @EnvironmentObject var store: InstructorStore
    @EnvironmentObject var departmentStore: DepartmentStore
    @State private var showingAdd = false
    @State private var searchText = ""

    private var sortedInstructors: [Instructor] {
        store.instructors.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var filteredInstructors: [Instructor] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return sortedInstructors
        }
        return sortedInstructors.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredInstructors) { instructor in
                    if let _ = store.instructors.firstIndex(where: { $0.id == instructor.id }) {
                        NavigationLink(instructor.name) {
                            EditInstructorView(instructor: instructor)
                                .environmentObject(store)
                                .environmentObject(departmentStore)
                        }
                    }
                }
                .onDelete(perform: deleteInstructors)
            }
            .overlay {
                if sortedInstructors.isEmpty {
                    ContentUnavailableView("No Instructors", systemImage: "person.2")
                }
            }
            .navigationTitle("Instructors")
            .toolbar {
                Button("Add") { showingAdd = true }
            }
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddInstructorSheet()
                    .environmentObject(store)
                    .environmentObject(departmentStore)
            }
        }
    }

    private func deleteInstructors(at offsets: IndexSet) {
        let ids = offsets.map { filteredInstructors[$0].id }
        store.remove(ids: ids)
    }
}

struct AddInstructorSheet: View {
    @EnvironmentObject var store: InstructorStore
    @EnvironmentObject var departmentStore: DepartmentStore
    @Environment(\.dismiss) var dismiss
    @State private var newInstructor = Instructor(name: "", departments: [])

    var body: some View {
        NavigationStack {
            Form {
                InstructorFormView(instructor: $newInstructor)
                    .environmentObject(departmentStore)
            }
            .navigationTitle("New Instructor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(newInstructor)
                        dismiss()
                    }
                    .disabled(newInstructor.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}

struct EditInstructorView: View {
    @EnvironmentObject var store: InstructorStore
    @EnvironmentObject var departmentStore: DepartmentStore
    @Environment(\.dismiss) var dismiss

    @State private var editedInstructor: Instructor
    private let originalInstructor: Instructor

    init(instructor: Instructor) {
        self._editedInstructor = State(initialValue: instructor)
        self.originalInstructor = instructor
    }

    var body: some View {
        Form {
            InstructorFormView(instructor: $editedInstructor)
                .environmentObject(departmentStore)
        }
        .navigationTitle("Edit Instructor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(editedInstructor == originalInstructor)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
    }

    private func save() {
        if let index = store.instructors.firstIndex(where: { $0.id == originalInstructor.id }) {
            store.instructors[index] = editedInstructor
            store.save()
        }
        dismiss()
    }
}

#Preview {
    InstructorsView()
        .environmentObject(InstructorStore())
        .environmentObject(DepartmentStore())
}
