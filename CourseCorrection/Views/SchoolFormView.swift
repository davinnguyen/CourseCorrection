import SwiftUI

struct SchoolFormView: View {
    @Binding var school: School

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Name", text: $school.name)
                TextField("Location", text: $school.location)
                Picker("Type", selection: $school.type) {
                    ForEach(SchoolType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

#Preview {
    SchoolFormView(school: .constant(School(name: "", location: "", type: .university)))
}
