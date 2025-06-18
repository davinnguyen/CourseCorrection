import SwiftUI

/// Displays the details of a ``School`` and allows editing the record.
struct SchoolDetailView: View {
    @EnvironmentObject var store: SchoolStore
    @EnvironmentObject var semesterStore: SemesterStore
    let school: School
    @State private var showingEdit = false
    @State private var showingAddSemester = false

    private var semestersForSchool: [Semester] {
        semesterStore.semesters
            .filter { $0.schoolID == school.id }
            .sorted { sortValue(for: $0.startDate) > sortValue(for: $1.startDate) }
    }

    var body: some View {
        Form {
            Section("Details") {
                Text(school.name)
                Text(school.location)
                Text(school.type.rawValue)
            }

            Section("Semesters") {
                if semestersForSchool.isEmpty {
                    Text("No Semesters")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(semestersForSchool) { semester in
                        NavigationLink {
                            EditSemesterView(semester: semester)
                                .environmentObject(semesterStore)
                                .environmentObject(store)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(semester.name)
                                Text("\(format(semester.startDate)) - \(format(semester.endDate))")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteSemesters)
                }
            }
        }
        .navigationTitle(school.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Semester") { showingAddSemester = true }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditSchoolView(school: school)
                .environmentObject(store)
        }
        .sheet(isPresented: $showingAddSemester) {
            AddSemesterSheet(schoolID: school.id)
                .environmentObject(semesterStore)
                .environmentObject(store)
        }
    }

    private func format(_ components: DateComponents) -> String {
        var parts: [String] = []
        if let month = components.month {
            parts.append(Calendar.current.monthSymbols[month - 1])
        }
        if let day = components.day {
            parts.append(String(day))
        }
        if let year = components.year {
            parts.append(String(year))
        }
        return parts.joined(separator: " ")
    }

    private func deleteSemesters(at offsets: IndexSet) {
        let ids = offsets.map { semestersForSchool[$0].id }
        semesterStore.remove(ids: ids)
    }

    private func sortValue(for components: DateComponents) -> Int {
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return year * 10000 + month * 100 + day
    }
}

struct AddSemesterSheet: View {
    @EnvironmentObject var semesterStore: SemesterStore
    @EnvironmentObject var schoolStore: SchoolStore
    @Environment(\.dismiss) var dismiss

    @State private var newSemester: Semester

    init(schoolID: UUID) {
        _newSemester = State(initialValue: Semester(name: "", schoolID: schoolID, startDate: DateComponents(), endDate: DateComponents()))
    }

    var body: some View {
        NavigationStack {
            Form {
                SemesterFormView(semester: $newSemester)
                    .environmentObject(schoolStore)
            }
            .navigationTitle("New Semester")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        semesterStore.add(newSemester)
                        dismiss()
                    }
                    .disabled(newSemester.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}

struct EditSemesterView: View {
    @EnvironmentObject var semesterStore: SemesterStore
    @EnvironmentObject var schoolStore: SchoolStore
    @Environment(\.dismiss) var dismiss

    @State private var editedSemester: Semester
    private let originalSemester: Semester

    init(semester: Semester) {
        _editedSemester = State(initialValue: semester)
        self.originalSemester = semester
    }

    var body: some View {
        Form {
            SemesterFormView(semester: $editedSemester)
                .environmentObject(schoolStore)
        }
        .navigationTitle("Edit Semester")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(editedSemester == originalSemester)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
    }

    private func save() {
        if let index = semesterStore.semesters.firstIndex(where: { $0.id == originalSemester.id }) {
            semesterStore.semesters[index] = editedSemester
            semesterStore.save()
        }
        dismiss()
    }
}

#Preview {
    SchoolDetailView(school: School(name: "Example", location: "", type: .university))
        .environmentObject(SchoolStore())
        .environmentObject(SemesterStore())
}
