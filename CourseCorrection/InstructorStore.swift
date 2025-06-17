import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

/// Stores `Instructor` data and persists changes in the iCloud container.
class InstructorStore: ObservableObject {
    @Published var instructors: [Instructor] = []

    private var fileURL: URL? {
        FileManager.default
            .url(forUbiquityContainerIdentifier: containerIdentifier)?
            .appendingPathComponent("instructors.json")
    }

    init() {
        load()
    }

    /// Loads instructors from the iCloud container.
    func load() {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url) else { return }

        if let decoded = try? JSONDecoder().decode([Instructor].self, from: data) {
            instructors = decoded
        }
    }

    /// Saves instructors to the iCloud container.
    func save() {
        guard let url = fileURL else { return }

        do {
            let data = try JSONEncoder().encode(instructors)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try data.write(to: url)
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
