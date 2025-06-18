import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

class CourseStore: ObservableObject {
    @Published var courses: [Course] = []
    @Published var usingICloud: Bool

    private let fileURL: URL

    init() {
        if let icloud = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            usingICloud = true
            fileURL = icloud.appendingPathComponent("courses.json")
        } else {
            usingICloud = false
            fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("courses.json")
        }
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }

        if let decoded = try? JSONDecoder().decode([Course].self, from: data) {
            courses = decoded
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(courses)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save courses: \(error)")
        }
    }

    func add(_ course: Course) {
        courses.append(course)
        save()
    }

    func remove(ids: [UUID]) {
        courses.removeAll { ids.contains($0.id) }
        save()
    }
}
