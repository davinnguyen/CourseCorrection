import SwiftUI

struct SchoolFormView: View {
    @Binding var school: School

    var body: some View {
        Form {
            TextField("Name", text: $school.name)
            TextField("Location", text: $school.location)
            Picker("Type", selection: $school.type) {
                ForEach(SchoolType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
        }
    }
}

#Preview {
    SchoolFormView(school: .constant(School(name: "Example", location: "", type: .university)))
}
