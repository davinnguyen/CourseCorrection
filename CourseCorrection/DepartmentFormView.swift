import SwiftUI

struct DepartmentFormView: View {
    @EnvironmentObject var schoolStore: SchoolStore
    @Binding var department: Department

    var body: some View {
        Group {
            TextField("Name", text: $department.name)
            Picker("School", selection: $department.schoolID) {
                ForEach(schoolStore.schools) { school in
                    Text(school.name).tag(school.id)
                }
            }
        }
    }
}

#Preview {
    DepartmentFormView(department: .constant(Department(name: "Example", schoolID: UUID())))
        .environmentObject(SchoolStore())
}
