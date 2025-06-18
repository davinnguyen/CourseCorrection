import Foundation

private let containerIdentifier = "iCloud.com.davin.CourseCorrection"

class ClassItemStore: ObservableObject {
    @Published var classItems: [ClassItem] = []
    @Published var usingICloud: Bool

    private let fileURL: URL

    init() {
        if let icloud = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) {
            usingICloud = true
            fileURL = icloud.appendingPathComponent("class_items.json")
        } else {
            usingICloud = false
            fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("class_items.json")
        }
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }

        if let decoded = try? JSONDecoder().decode([ClassItem].self, from: data) {
            classItems = decoded
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(classItems)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save class items: \(error)")
        }
    }

    func add(_ classItem: ClassItem) {
        classItems.append(classItem)
        save()
    }

    func remove(ids: [UUID]) {
        classItems.removeAll { ids.contains($0.id) }
        save()
    }
}
