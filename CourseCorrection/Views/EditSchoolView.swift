import SwiftUI

struct EditSchoolView: View {
    @Binding var school: School

    var body: some View {
        NavigationStack {
            SchoolFormView(school: $school)
                .navigationTitle("Edit School")
        }
    }
}

#Preview {
    EditSchoolView(school: .constant(School(name: "", location: "", type: .university)))
}
