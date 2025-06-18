import SwiftUI

struct SemesterFormView: View {
    @EnvironmentObject var schoolStore: SchoolStore
    @Binding var semester: Semester

    var body: some View {
        Group {
            TextField("Name", text: $semester.name)
            Picker("School", selection: $semester.schoolID) {
                ForEach(schoolStore.schools) { school in
                    Text(school.name).tag(school.id)
                }
            }
            Section("Start Date") {
                DateComponentsPicker(components: $semester.startDate)
            }
            Section("End Date") {
                DateComponentsPicker(components: $semester.endDate)
            }
        }
    }
}

#Preview {
    SemesterFormView(semester: .constant(Semester(name: "Fall", schoolID: UUID(), startDate: DateComponents(year: 2024, month: 8, day: 20), endDate: DateComponents(year: 2024, month: 12, day: 15))))
        .environmentObject(SchoolStore())
}
