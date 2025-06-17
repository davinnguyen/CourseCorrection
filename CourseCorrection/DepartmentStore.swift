import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

/// Manages the list of `Department` objects and persists them to iCloud using
/// `FileManager`.
class DepartmentStore: ObservableObject {
    @Published var departments: [Department] = []

    private var fileURL: URL? {
        FileManager.default
            .url(forUbiquityContainerIdentifier: containerIdentifier)?
            .appendingPathComponent("departments.json")
    }

    init() {
        load()
    }

    /// Loads stored departments from iCloud, if available.
    func load() {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url) else { return }

        if let decoded = try? JSONDecoder().decode([Department].self, from: data) {
            departments = decoded
        }
    }

    /// Saves the current departments list to iCloud.
    func save() {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(departments)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try data.write(to: url)
        } catch {
            print("Failed to save departments: \(error)")
        }
    }

    /// Adds a department and immediately persists the change.
    func add(_ department: Department) {
        departments.append(department)
        save()
    }

    /// Removes departments with the provided identifiers.
    func remove(ids: [UUID]) {
        departments.removeAll { ids.contains($0.id) }
        save()
    }
}
