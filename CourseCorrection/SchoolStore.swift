import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

/// View model responsible for persisting `School` objects in iCloud or locally.
class SchoolStore: ObservableObject {
    @Published var schools: [School] = []
    @Published var usingICloud: Bool

    private let fileURL: URL

    init() {
        if let icloud = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            usingICloud = true
            fileURL = icloud.appendingPathComponent("schools.json")
        } else {
            usingICloud = false
            fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("schools.json")
        }
        load()
    }

    /// Loads schools from persistent storage.
    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }

        if let decoded = try? JSONDecoder().decode([School].self, from: data) {
            schools = decoded
        }
    }

    /// Saves schools to persistent storage.
    func save() {
        do {
            let data = try JSONEncoder().encode(schools)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save schools: \(error)")
        }
    }

    func add(_ school: School) {
        schools.append(school)
        save()
    }

    func remove(ids: [UUID]) {
        schools.removeAll { ids.contains($0.id) }
        save()
    }
}
