import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

/// Stores `Semester` objects and persists them either in iCloud or locally.
class SemesterStore: ObservableObject {
    @Published var semesters: [Semester] = []
    @Published var usingICloud: Bool

    private let fileURL: URL

    init() {
        if let icloud = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            usingICloud = true
            fileURL = icloud.appendingPathComponent("semesters.json")
        } else {
            usingICloud = false
            fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("semesters.json")
        }
        load()
    }

    /// Loads semesters from persistent storage.
    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }

        if let decoded = try? JSONDecoder().decode([Semester].self, from: data) {
            semesters = decoded
        }
    }

    /// Saves semesters to persistent storage.
    func save() {
        do {
            let data = try JSONEncoder().encode(semesters)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save semesters: \(error)")
        }
    }

    /// Adds a semester and immediately persists the change.
    func add(_ semester: Semester) {
        semesters.append(semester)
        save()
    }

    /// Removes semesters with the provided identifiers.
    func remove(ids: [UUID]) {
        semesters.removeAll { ids.contains($0.id) }
        save()
    }
}
