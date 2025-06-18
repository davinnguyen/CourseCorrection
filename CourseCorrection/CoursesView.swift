import SwiftUI

struct CoursesView: View {
    @EnvironmentObject var store: CourseStore
    @EnvironmentObject var subjectStore: SubjectStore
    @State private var showingAdd = false
    @State private var searchText = ""

    private var sortedCourses: [Course] {
        store.courses.sorted { $0.courseNumber.localizedCaseInsensitiveCompare($1.courseNumber) == .orderedAscending }
    }

    private var filteredCourses: [Course] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return sortedCourses
        }
        return sortedCourses.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.courseNumber.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCourses) { course in
                    if let _ = store.courses.firstIndex(where: { $0.id == course.id }) {
                        NavigationLink("\(course.courseNumber) - \(course.title)") {
                            EditCourseView(course: course)
                                .environmentObject(store)
                                .environmentObject(subjectStore)
                        }
                    }
                }
                .onDelete(perform: deleteCourses)
            }
            .overlay {
                if sortedCourses.isEmpty {
                    ContentUnavailableView("No Courses", systemImage: "book")
                }
            }
            .navigationTitle("Courses")
            .toolbar { Button("Add") { showingAdd = true } }
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddCourseSheet()
                    .environmentObject(store)
                    .environmentObject(subjectStore)
            }
        }
    }

    private func deleteCourses(at offsets: IndexSet) {
        let ids = offsets.map { filteredCourses[$0].id }
        store.remove(ids: ids)
    }
}

struct AddCourseSheet: View {
    @EnvironmentObject var store: CourseStore
    @EnvironmentObject var subjectStore: SubjectStore
    @Environment(\.dismiss) var dismiss
    @State private var newCourse = Course(subjectID: UUID(), courseNumber: "", title: "", description: "", units: 0)

    var body: some View {
        NavigationStack {
            Form {
                CourseFormView(course: $newCourse)
                    .environmentObject(subjectStore)
            }
            .navigationTitle("New Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(newCourse)
                        dismiss()
                    }
                    .disabled(newCourse.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}

struct EditCourseView: View {
    @EnvironmentObject var store: CourseStore
    @EnvironmentObject var subjectStore: SubjectStore
    @Environment(\.dismiss) var dismiss

    @State private var editedCourse: Course
    private let originalCourse: Course

    init(course: Course) {
        self._editedCourse = State(initialValue: course)
        self.originalCourse = course
    }

    var body: some View {
        Form {
            CourseFormView(course: $editedCourse)
                .environmentObject(subjectStore)
        }
        .navigationTitle("Edit Course")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(editedCourse == originalCourse)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
    }

    private func save() {
        if let index = store.courses.firstIndex(where: { $0.id == originalCourse.id }) {
            store.courses[index] = editedCourse
            store.save()
        }
        dismiss()
    }
}

#Preview {
    CoursesView()
        .environmentObject(CourseStore())
        .environmentObject(SubjectStore())
}
