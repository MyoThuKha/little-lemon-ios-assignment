import CoreData
@objc(Dish)
final class Dish: NSManagedObject, Identifiable {
    @NSManaged var title: String
    @NSManaged var image: String
    @NSManaged var price: String
    @NSManaged var details: String
    @NSManaged var category: String
}
