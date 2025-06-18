import SwiftUI

struct ClassItemsView: View {
    @EnvironmentObject var store: ClassItemStore
    @EnvironmentObject var courseStore: CourseStore
    @EnvironmentObject var instructorStore: InstructorStore
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.classItems) { item in
                    if let course = courseStore.courses.first(where: { $0.id == item.courseID }),
                       let index = store.classItems.firstIndex(where: { $0.id == item.id }) {
                        NavigationLink("\(course.courseNumber) - \(course.title)") {
                            EditClassItemView(classItem: item)
                                .environmentObject(store)
                                .environmentObject(courseStore)
                                .environmentObject(instructorStore)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .overlay {
                if store.classItems.isEmpty {
                    ContentUnavailableView("No Classes", systemImage: "calendar")
                }
            }
            .navigationTitle("Classes")
            .toolbar { Button("Add") { showingAdd = true } }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddClassItemSheet()
                    .environmentObject(store)
                    .environmentObject(courseStore)
                    .environmentObject(instructorStore)
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let ids = offsets.map { store.classItems[$0].id }
        store.remove(ids: ids)
    }
}

struct AddClassItemSheet: View {
    @EnvironmentObject var store: ClassItemStore
    @EnvironmentObject var courseStore: CourseStore
    @EnvironmentObject var instructorStore: InstructorStore
    @Environment(\.dismiss) var dismiss
    @State private var newItem = ClassItem(courseID: UUID(), semesterID: nil, instructorID: nil)

    var body: some View {
        NavigationStack {
            Form {
                ClassItemFormView(classItem: $newItem)
                    .environmentObject(courseStore)
                    .environmentObject(instructorStore)
            }
            .navigationTitle("New Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(newItem)
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

struct EditClassItemView: View {
    @EnvironmentObject var store: ClassItemStore
    @EnvironmentObject var courseStore: CourseStore
    @EnvironmentObject var instructorStore: InstructorStore
    @Environment(\.dismiss) var dismiss

    @State private var editedItem: ClassItem
    private let originalItem: ClassItem

    init(classItem: ClassItem) {
        self._editedItem = State(initialValue: classItem)
        self.originalItem = classItem
    }

    var body: some View {
        Form {
            ClassItemFormView(classItem: $editedItem)
                .environmentObject(courseStore)
                .environmentObject(instructorStore)
        }
        .navigationTitle("Edit Class")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(editedItem == originalItem)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
    }

    private func save() {
        if let index = store.classItems.firstIndex(where: { $0.id == originalItem.id }) {
            store.classItems[index] = editedItem
            store.save()
        }
        dismiss()
    }
}

#Preview {
    ClassItemsView()
        .environmentObject(ClassItemStore())
        .environmentObject(CourseStore())
        .environmentObject(InstructorStore())
}
