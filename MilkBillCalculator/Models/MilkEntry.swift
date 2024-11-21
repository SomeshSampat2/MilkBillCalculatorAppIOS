import Foundation

enum MilkType: String, CaseIterable, Codable {
    case cow = "Cow"
    case buffalo = "Buffalo"
}

struct MilkEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var type: MilkType
    var liters: Double
    var pricePerLiter: Double
    var isDelivered: Bool
    
    var totalPrice: Double {
        return liters * pricePerLiter
    }
}

class MilkStore: ObservableObject {
    @Published var entries: [MilkEntry] = []
    private let saveKey = "MilkEntries"
    
    init() {
        loadEntries()
    }
    
    func addEntry(_ entry: MilkEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func updateEntry(_ entry: MilkEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveEntries()
        }
    }
    
    func deleteEntry(_ entry: MilkEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([MilkEntry].self, from: data) {
            entries = decoded
        }
    }
}
