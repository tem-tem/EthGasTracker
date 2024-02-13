//
//  CustomActionDataManager.swift
//  EthGasTracker
//
//  Created by Tem on 2/9/24.
//
import Foundation
import CoreData

class CustomActionDataManager: ObservableObject {
    let MAX_PINNED = 9
    let container: NSPersistentContainer
    @Published var actions: [CustomActionEntity] = []
    @Published var pinnedActions: [CustomActionEntity] = []

    init() {
        container = NSPersistentContainer(name: "Gas")
        let groupName = "group.TA.EthGas"
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)?.appendingPathComponent("Gas.sqlite") else {
            fatalError("Could not find the app group directory.")
        }

        let description = NSPersistentStoreDescription(url: url)
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        fetchCustomActions()
    }
    
    func reorder(actions: [CustomActionEntity]) {
        let context = container.viewContext
        for (index, action) in actions.enumerated() {
            action.order = Int64(index)
            action.pinned = action.order < MAX_PINNED
        }
        saveContext(context: context)
    }
    
    func addCustomAction(key: String, group: String, name: String, limit: Int64, isServerAction: Bool) {
        let context = container.viewContext
        let newAction = CustomActionEntity(context: context)
        newAction.id = UUID()
        newAction.key = key
        newAction.group = group
        newAction.name = name
        newAction.limit = limit
        newAction.order = Int64(actions.count)
        newAction.pinned = newAction.order < MAX_PINNED
        newAction.isServerAction = isServerAction
        
        saveContext(context: context)
    }
    
    func updateCustomAction(_ action: CustomActionEntity, key: String, group: String, name: String, limit: Int64, isServerAction: Bool) {
        let context = container.viewContext
        action.key = key
        action.group = group
        action.name = name
        action.limit = limit
        action.isServerAction = isServerAction

        saveContext(context: context)
    }

    func getAllCustomActions() -> [CustomActionEntity] {
        let context = container.viewContext
        let request: NSFetchRequest<CustomActionEntity> = CustomActionEntity.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching CustomActionEntities: \(error)")
            return []
        }
    }
    
    func deleteCustomAction(_ action: CustomActionEntity) {
        let context = container.viewContext
        context.delete(action)
        saveContext(context: context)
    }
    
    func moveCustomAction(from source: IndexSet, to destination: Int) {
        var revisedActions = actions
        revisedActions.move(fromOffsets: source, toOffset: destination)
        for (index, action) in revisedActions.enumerated() {
            action.order = Int64(index)
        }
        saveContext(context: container.viewContext)
    }
    
    private func saveContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Handle the Core Data error
                print("Core Data save error: \(error)")
            }
        }
        fetchCustomActions()
    }
    
    func fetchCustomActions() {
        self.actions = getAllCustomActions().sorted(by: { $0.order < $1.order })
        self.pinnedActions = self.actions.filter { $0.pinned }
    }
    
    func purgeCustomActions() {
        let context = container.viewContext
        for action in actions {
            context.delete(action)
        }
        saveContext(context: context)
    }
}

extension CustomActionEntity {
    static func calcCost(for limit: Double, ethPrice: Double, gas: Double) -> Double {
        if let costInEth = Double(String(format: "%.6f", (gas * limit) / 1e9)) {
            let costInFiat = costInEth * ethPrice
            return costInFiat
        } else {
            return 0
        }
    }
}

extension CustomActionEntity {
    static func placeholder(in context: NSManagedObjectContext? = nil) -> CustomActionEntity {
        // Use the provided context or create a temporary in-memory context for the preview
        let context = context ?? temporaryInMemoryManagedObjectContext()
        let entity = CustomActionEntity(context: context)
        entity.key = "0x000"
        entity.group = "Placeholder"
        entity.name = "Placeholder"
        entity.limit = 100000
        entity.order = 0
        entity.pinned = false
        entity.isServerAction = false
        return entity
    }

    private static func temporaryInMemoryManagedObjectContext() -> NSManagedObjectContext {
        // Create an in-memory NSPersistentContainer
        let container = NSPersistentContainer(name: "Gas")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        
        return container.viewContext
    }
}
