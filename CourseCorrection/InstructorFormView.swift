import SwiftUI

struct InstructorFormView: View {
    @Binding var instructor: Instructor

    var body: some View {
        Group {
            TextField("Name", text: $instructor.name)
            TextField("Department", text: $instructor.department)
        }
    }
}

#Preview {
    InstructorFormView(instructor: .constant(Instructor(name: "Example", department: "Math")))
}
