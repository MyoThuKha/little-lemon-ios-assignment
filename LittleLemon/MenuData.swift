import Foundation
import CoreData

enum MenuData {
    static let url = URL(string: "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json")!
    static func fetch() async throws -> [MenuItem] {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(MenuList.self, from: data).menu
    }
    // Call on the managed object context's queue. Only replace the cache after
    // the network request and decoding succeed; rollback protects the old cache.
    static func save(_ items: [MenuItem], in context: NSManagedObjectContext) throws {
        do {
            let request = NSFetchRequest<Dish>(entityName: "Dish")
            for dish in try context.fetch(request) { context.delete(dish) }
            for item in items {
                let dish = Dish(context: context)
                dish.title = item.title; dish.image = item.image; dish.price = item.price
                dish.details = item.description; dish.category = item.category
            }
            try context.save()
        } catch { context.rollback(); throw error }
    }
}

enum MenuQuery {
    static func sortDescriptors() -> [NSSortDescriptor] {
        [NSSortDescriptor(key: "title", ascending: true,
                          selector: #selector(NSString.localizedStandardCompare(_:)))]
    }
    static func predicate(searchText: String, category: String) -> NSPredicate {
        var predicates: [NSPredicate] = []
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !search.isEmpty { predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", search)) }
        if !category.isEmpty { predicates.append(NSPredicate(format: "category == %@", category)) }
        return predicates.isEmpty ? NSPredicate(value: true) : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
