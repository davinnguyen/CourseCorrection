import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

/// Persists `CourseResultEntry` objects either in iCloud or locally.
class CourseResultEntryStore: ObservableObject {
    @Published var entries: [CourseResultEntry] = []
    @Published var usingICloud: Bool

    private let fileURL: URL

    init() {
        if let icloud = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            usingICloud = true
            fileURL = icloud.appendingPathComponent("course_results.json")
        } else {
            usingICloud = false
            fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("course_results.json")
        }
        load()
    }

    /// Loads stored entries from persistent storage.
    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }

        if let decoded = try? JSONDecoder().decode([CourseResultEntry].self, from: data) {
            entries = decoded
        }
    }

    /// Saves entries to persistent storage.
    func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save course results: \(error)")
        }
    }

    /// Adds an entry and persists the change.
    func add(_ entry: CourseResultEntry) {
        entries.append(entry)
        save()
    }

    /// Removes entries with the provided identifiers.
    func remove(ids: [UUID]) {
        entries.removeAll { ids.contains($0.id) }
        save()
    }
}
