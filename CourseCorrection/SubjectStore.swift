import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

class SubjectStore: ObservableObject {
    @Published var subjects: [Subject] = []
    @Published var usingICloud: Bool

    private let fileURL: URL

    init() {
        if let icloud = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            usingICloud = true
            fileURL = icloud.appendingPathComponent("subjects.json")
        } else {
            usingICloud = false
            fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("subjects.json")
        }
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }

        if let decoded = try? JSONDecoder().decode([Subject].self, from: data) {
            subjects = decoded
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(subjects)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save subjects: \(error)")
        }
    }

    func add(_ subject: Subject) {
        subjects.append(subject)
        save()
    }

    func remove(ids: [UUID]) {
        subjects.removeAll { ids.contains($0.id) }
        save()
    }
}
