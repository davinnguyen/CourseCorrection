import SwiftUI

struct InstructorsView: View {
    @EnvironmentObject var store: InstructorStore
    @EnvironmentObject var departmentStore: DepartmentStore
    @State private var showingAdd = false

    private var sortedInstructors: [Instructor] {
        store.instructors.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedInstructors) { instructor in
                    if let index = store.instructors.firstIndex(where: { $0.id == instructor.id }) {
                        NavigationLink(instructor.name) {
                            InstructorFormView(instructor: $store.instructors[index])
                                .environmentObject(departmentStore)
                                .navigationTitle("Edit Instructor")
                        }
                    }
                }
                .onDelete(perform: deleteInstructors)
            }
            .navigationTitle("Instructors")
            .toolbar {
                Button("Add") { showingAdd = true }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddInstructorSheet()
                    .environmentObject(store)
                    .environmentObject(departmentStore)
            }
        }
    }

    private func deleteInstructors(at offsets: IndexSet) {
        for index in offsets {
            let id = sortedInstructors[index].id
            if let original = store.instructors.firstIndex(where: { $0.id == id }) {
                store.instructors.remove(at: original)
            }
        }
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
                        store.instructors.append(newInstructor)
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

#Preview {
    InstructorsView()
        .environmentObject(InstructorStore())
        .environmentObject(DepartmentStore())
}
