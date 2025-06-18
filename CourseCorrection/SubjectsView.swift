import SwiftUI

struct SubjectsView: View {
    @EnvironmentObject var store: SubjectStore
    @EnvironmentObject var schoolStore: SchoolStore
    @State private var showingAdd = false
    @State private var searchText = ""

    private var sortedSubjects: [Subject] {
        store.subjects.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var filteredSubjects: [Subject] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return sortedSubjects
        }
        return sortedSubjects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var sortedSchools: [School] {
        schoolStore.schools.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func subjects(for school: School) -> [Subject] {
        filteredSubjects.filter { $0.schoolID == school.id }
    }

    private var unknownSubjects: [Subject] {
        filteredSubjects.filter { subj in
            !schoolStore.schools.contains(where: { $0.id == subj.schoolID })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedSchools) { school in
                    if !subjects(for: school).isEmpty {
                        Section(header: Text(school.name)) {
                            ForEach(subjects(for: school)) { subject in
                                if let index = store.subjects.firstIndex(where: { $0.id == subject.id }) {
                                    NavigationLink(subject.name) {
                                        EditSubjectView(subject: subject)
                                            .environmentObject(store)
                                            .environmentObject(schoolStore)
                                    }
                                }
                            }
                            .onDelete { offsets in
                                deleteSubjects(at: offsets, in: subjects(for: school))
                            }
                        }
                    }
                }

                if !unknownSubjects.isEmpty {
                    Section(header: Text("Unknown School")) {
                        ForEach(unknownSubjects) { subject in
                            if let _ = store.subjects.firstIndex(where: { $0.id == subject.id }) {
                                NavigationLink(subject.name) {
                                    EditSubjectView(subject: subject)
                                        .environmentObject(store)
                                        .environmentObject(schoolStore)
                                }
                            }
                        }
                        .onDelete { offsets in
                            deleteSubjects(at: offsets, in: unknownSubjects)
                        }
                    }
                }
            }
            .overlay {
                if sortedSubjects.isEmpty {
                    ContentUnavailableView("No Subjects", systemImage: "book")
                }
            }
            .navigationTitle("Subjects")
            .toolbar {
                Button("Add") { showingAdd = true }
            }
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddSubjectSheet()
                    .environmentObject(store)
                    .environmentObject(schoolStore)
            }
        }
    }

    private func deleteSubjects(at offsets: IndexSet, in list: [Subject]) {
        let ids = offsets.map { list[$0].id }
        store.remove(ids: ids)
    }
}

struct AddSubjectSheet: View {
    @EnvironmentObject var store: SubjectStore
    @EnvironmentObject var schoolStore: SchoolStore
    @Environment(\.dismiss) var dismiss
    @State private var newSubject = Subject(name: "", schoolID: UUID())

    var body: some View {
        NavigationStack {
            Form {
                SubjectFormView(subject: $newSubject)
                    .environmentObject(schoolStore)
            }
            .navigationTitle("New Subject")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(newSubject)
                        dismiss()
                    }
                    .disabled(newSubject.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}

struct EditSubjectView: View {
    @EnvironmentObject var store: SubjectStore
    @EnvironmentObject var schoolStore: SchoolStore
    @Environment(\.dismiss) var dismiss

    @State private var editedSubject: Subject
    private let originalSubject: Subject

    init(subject: Subject) {
        self._editedSubject = State(initialValue: subject)
        self.originalSubject = subject
    }

    var body: some View {
        Form {
            SubjectFormView(subject: $editedSubject)
                .environmentObject(schoolStore)
        }
        .navigationTitle("Edit Subject")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(editedSubject == originalSubject)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
    }

    private func save() {
        if let index = store.subjects.firstIndex(where: { $0.id == originalSubject.id }) {
            store.subjects[index] = editedSubject
            store.save()
        }
        dismiss()
    }
}

#Preview {
    SubjectsView()
        .environmentObject(SubjectStore())
        .environmentObject(SchoolStore())
}
