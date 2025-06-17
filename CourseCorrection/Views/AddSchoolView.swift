import SwiftUI

struct AddSchoolView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: SchoolStore
    @State private var school = School(name: "", location: "", type: .university)

    var body: some View {
        NavigationStack {
            SchoolFormView(school: $school)
                .navigationTitle("Add School")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.add(school)
                            dismiss()
                        }
                        .disabled(school.name.isEmpty)
                    }
                }
        }
    }
}

#Preview {
    AddSchoolView(store: SchoolStore())
}
