import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

/// Stores `Instructor` data and persists changes either in iCloud or locally.
class InstructorStore: ObservableObject {
    @Published var instructors: [Instructor] = []
    @Published var usingICloud: Bool

    private let fileURL: URL

    init() {
        if let icloud = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            usingICloud = true
            fileURL = icloud.appendingPathComponent("instructors.json")
        } else {
            usingICloud = false
            fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("instructors.json")
        }
        load()
    }

    /// Loads instructors from persistent storage.
    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }

        if let decoded = try? JSONDecoder().decode([Instructor].self, from: data) {
            instructors = decoded
        }
    }

    /// Saves instructors to persistent storage.
    func save() {
        do {
            let data = try JSONEncoder().encode(instructors)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save instructors: \(error)")
        }
    }

    func add(_ instructor: Instructor) {
        instructors.append(instructor)
        save()
    }

    func remove(ids: [UUID]) {
        instructors.removeAll { ids.contains($0.id) }
        save()
    }
}
