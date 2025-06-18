import SwiftUI

struct SubjectFormView: View {
    @EnvironmentObject var schoolStore: SchoolStore
    @Binding var subject: Subject

    var body: some View {
        Group {
            TextField("Name", text: $subject.name)
            Picker("School", selection: $subject.schoolID) {
                ForEach(schoolStore.schools) { school in
                    Text(school.name).tag(school.id)
                }
            }
        }
    }
}

#Preview {
    SubjectFormView(subject: .constant(Subject(name: "Example", schoolID: UUID())))
        .environmentObject(SchoolStore())
}
