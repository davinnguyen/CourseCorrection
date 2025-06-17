import SwiftUI

struct ContentView: View {
    @StateObject private var store = SchoolStore()
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach($store.schools) { $school in
                    NavigationLink(destination: EditSchoolView(school: $school)) {
                        VStack(alignment: .leading) {
                            Text(school.name)
                                .font(.headline)
                            Text(school.type.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Schools")
            .toolbar {
                Button("Add") { showAdd = true }
            }
            .sheet(isPresented: $showAdd) {
                AddSchoolView(store: store)
            }
        }
    }
}

#Preview {
    ContentView()
}
