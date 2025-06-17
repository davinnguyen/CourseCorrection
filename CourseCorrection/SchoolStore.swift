import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

/// View model responsible for persisting `School` objects in iCloud.
class SchoolStore: ObservableObject {
    @Published var schools: [School] = []

    private var fileURL: URL? {
        FileManager.default
            .url(forUbiquityContainerIdentifier: containerIdentifier)?
            .appendingPathComponent("schools.json")
    }

    init() {
        load()
    }

    /// Loads schools from the iCloud container.
    func load() {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url) else { return }

        if let decoded = try? JSONDecoder().decode([School].self, from: data) {
            schools = decoded
        }
    }

    /// Saves schools to the iCloud container.
    func save() {
        guard let url = fileURL else { return }

        do {
            let data = try JSONEncoder().encode(schools)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try data.write(to: url)
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
