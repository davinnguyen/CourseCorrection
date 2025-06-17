import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

/// Manages the list of `Department` objects and persists them either to iCloud
/// or to on-device storage.
class DepartmentStore: ObservableObject {
    @Published var departments: [Department] = []
    @Published var usingICloud: Bool

    private let fileURL: URL

    init() {
        if let icloud = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            usingICloud = true
            fileURL = icloud.appendingPathComponent("departments.json")
        } else {
            usingICloud = false
            fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("departments.json")
        }
        load()
    }

    /// Loads stored departments from persistent storage, if available.
    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }

        if let decoded = try? JSONDecoder().decode([Department].self, from: data) {
            departments = decoded
        }
    }

    /// Saves the current departments list.
    func save() {
        do {
            let data = try JSONEncoder().encode(departments)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try data.write(to: fileURL)
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
