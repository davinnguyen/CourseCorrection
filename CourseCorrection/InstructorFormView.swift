import SwiftUI

struct InstructorFormView: View {
    @EnvironmentObject var departmentStore: DepartmentStore
    @Binding var instructor: Instructor

    var body: some View {
        Group {
            TextField("Name", text: $instructor.name)
            Section("Departments") {
                ForEach(departmentStore.departments) { department in
                    Toggle(department.name, isOn: Binding(
                        get: { instructor.departments.contains(department.id) },
                        set: { isOn in
                            if isOn {
                                instructor.departments.insert(department.id)
                            } else {
                                instructor.departments.remove(department.id)
                            }
                        }
                    ))
                }
            }
        }
    }
}
#Preview {
    InstructorFormView(instructor: .constant(Instructor(name: "Example", departments: [])))
        .environmentObject(DepartmentStore())
}
