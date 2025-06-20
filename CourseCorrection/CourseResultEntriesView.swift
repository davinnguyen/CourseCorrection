import SwiftUI

struct CourseResultEntriesView: View {
    @EnvironmentObject var store: CourseResultEntryStore
    @EnvironmentObject var classItemStore: ClassItemStore
    @EnvironmentObject var courseStore: CourseStore
    @EnvironmentObject var semesterStore: SemesterStore
    @State private var showingAdd = false

    /// Groups entries by the semester of their associated class.
    private var grouped: [(semester: Semester?, entries: [CourseResultEntry])] {
        let dict = Dictionary(grouping: store.entries) { entry -> Semester? in
            guard let item = classItemStore.classItems.first(where: { $0.id == entry.classID }),
                  let semID = item.semesterID else { return nil }
            return semesterStore.semesters.first(where: { $0.id == semID })
        }
        return dict.map { ($0.key, $0.value) }
            .sorted { lhs, rhs in
                switch (lhs.semester, rhs.semester) {
                case let (l?, r?):
                    return l.name < r.name
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                default:
                    return true
                }
            }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.semester?.id) { group in
                    Section(header: Text(group.semester?.name ?? "No Semester")) {
                        ForEach(group.entries) { entry in
                            if let item = classItemStore.classItems.first(where: { $0.id == entry.classID }),
                               let course = courseStore.courses.first(where: { $0.id == item.courseID }) {
                                NavigationLink("\(course.courseNumber) - \(course.title) : \(entry.courseResult?.description ?? "None")") {
                                    EditCourseResultEntryView(entry: entry)
                                        .environmentObject(store)
                                        .environmentObject(classItemStore)
                                        .environmentObject(courseStore)
                                        .environmentObject(semesterStore)
                                }
                            }
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { group.entries[$0].id }
                            store.remove(ids: ids)
                        }
                    }
                }
            }
            .overlay {
                if store.entries.isEmpty {
                    ContentUnavailableView("No Results", systemImage: "chart.bar")
                }
            }
            .navigationTitle("Results")
            .toolbar { Button("Add") { showingAdd = true } }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddCourseResultEntrySheet()
                    .environmentObject(store)
                    .environmentObject(classItemStore)
                    .environmentObject(courseStore)
            }
        }
    }
}

struct AddCourseResultEntrySheet: View {
    @EnvironmentObject var store: CourseResultEntryStore
    @EnvironmentObject var classItemStore: ClassItemStore
    @EnvironmentObject var courseStore: CourseStore
    @Environment(\.dismiss) var dismiss
    @State private var newEntry = CourseResultEntry(classID: UUID(), courseResult: nil)

    var body: some View {
        NavigationStack {
            Form {
                CourseResultEntryFormView(entry: $newEntry)
                    .environmentObject(classItemStore)
                    .environmentObject(courseStore)
            }
            .navigationTitle("New Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(newEntry)
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

struct EditCourseResultEntryView: View {
    @EnvironmentObject var store: CourseResultEntryStore
    @EnvironmentObject var classItemStore: ClassItemStore
    @EnvironmentObject var courseStore: CourseStore
    @EnvironmentObject var semesterStore: SemesterStore
    @Environment(\.dismiss) var dismiss

    @State private var editedEntry: CourseResultEntry
    private let originalEntry: CourseResultEntry

    init(entry: CourseResultEntry) {
        self._editedEntry = State(initialValue: entry)
        self.originalEntry = entry
    }

    var body: some View {
        Form {
            CourseResultEntryFormView(entry: $editedEntry)
                .environmentObject(classItemStore)
                .environmentObject(courseStore)
        }
        .navigationTitle("Edit Result")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(editedEntry == originalEntry)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
    }

    private func save() {
        if let index = store.entries.firstIndex(where: { $0.id == originalEntry.id }) {
            store.entries[index] = editedEntry
            store.save()
        }
        dismiss()
    }
}

#Preview {
    CourseResultEntriesView()
        .environmentObject(CourseResultEntryStore())
        .environmentObject(ClassItemStore())
        .environmentObject(CourseStore())
        .environmentObject(SemesterStore())
}
