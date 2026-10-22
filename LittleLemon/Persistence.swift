import CoreData

// Based on the course's Persistence.swift. Unlike its /dev/null store,
// this keeps a SQLite cache between launches and surfaces loading errors.
struct PersistenceController {
    static let shared: PersistenceController = {
        do { return try PersistenceController() }
        catch { fatalError("Unable to load the menu database: \(error)") }
    }()
    let container: NSPersistentContainer
    init(inMemory: Bool = false, model: NSManagedObjectModel? = nil) throws {
        if let model { container = NSPersistentContainer(name: "ExampleDatabase", managedObjectModel: model) }
        else { container = NSPersistentContainer(name: "ExampleDatabase") }
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.persistentStoreDescriptions.first?.shouldAddStoreAsynchronously = false
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if let loadError { throw loadError }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
