import Foundation
import UIKit
import CoreData

//class CoreDataHandler {
//
//    // Shared instance for Singleton pattern
//    static let shared = CoreDataHandler()
//
////    // Reference to Managed Object Context
////    let context: NSManagedObjectContext
////
////    private init() {
////        // Assuming you have a setup like the default Xcode template
////        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
////    }
//
//    // MARK: - Create
//    func createCustomAction(id: UUID, limit: Int64, name: String) {
//        let newAction = CustomActionEntity(context: context)
//        newAction.id = id
//        newAction.limit = limit
//        newAction.name = name
//
//        do {
//            try context.save()
//        } catch {
//            print("Failed to save custom action: \(error)")
//        }
//    }
//
//    // MARK: - Read
//    func fetchCustomActions() -> [CustomActionEntity] {
//        do {
//            let fetchRequest: NSFetchRequest<CustomActionEntity> = CustomActionEntity.fetchRequest()
//            let actions = try context.fetch(fetchRequest)
//            return actions
//        } catch {
//            print("Failed to fetch custom actions: \(error)")
//            return []
//        }
//    }
//
//    // MARK: - Update
//    func updateCustomAction(action: CustomActionEntity, newLimit: Int64, newName: String) {
//        action.limit = newLimit
//        action.name = newName
//
//        do {
//            try context.save()
//        } catch {
//            print("Failed to update custom action: \(error)")
//        }
//    }
//
//    // MARK: - Delete
//    func deleteCustomAction(action: CustomActionEntity) {
//        context.delete(action)
//
//        do {
//            try context.save()
//        } catch {
//            print("Failed to delete custom action: \(error)")
//        }
//    }
//}
