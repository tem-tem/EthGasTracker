//
//  AddressTrackerDataController.swift
//  EthGasTracker
//
//  Created by Tem on 10/5/25.
//

import CoreData
import Foundation
import SwiftUI
import Combine

class AddressTrackerDataController: ObservableObject {
    let container = NSPersistentContainer(name: "Gas")
    
    static let shared = AddressTrackerDataController()
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("❌ Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - Address Operations
    
    func fetchAddresses() -> [AddressLocal] {
        let request = AddressLocal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AddressLocal.createdAt, ascending: false)]
        request.relationshipKeyPathsForPrefetching = ["network"]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("❌ Failed to fetch addresses: \(error)")
            return []
        }
    }
    
    func fetchAddresses(for networkLocal: NetworkLocal) -> [AddressLocal] {
        let request = AddressLocal.fetchRequest()
        request.predicate = NSPredicate(format: "network == %@", networkLocal)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AddressLocal.createdAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("❌ Failed to fetch addresses for network: \(error)")
            return []
        }
    }
    
    func fetchAddresses(forNetworkKey networkKey: String) -> [AddressLocal] {
        let request = AddressLocal.fetchRequest()
        request.predicate = NSPredicate(format: "network.key == %@", networkKey)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AddressLocal.createdAt, ascending: false)]
        request.relationshipKeyPathsForPrefetching = ["network"]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("❌ Failed to fetch addresses for network key \(networkKey): \(error)")
            return []
        }
    }
    
    func findAddress(address: String, networkLocal: NetworkLocal) -> AddressLocal? {
        let request = AddressLocal.fetchRequest()
        request.predicate = NSPredicate(format: "address == %@ AND network == %@", address, networkLocal)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("❌ Failed to find address: \(error)")
            return nil
        }
    }
    
    func findAddress(address: String, networkKey: String) -> AddressLocal? {
        let request = AddressLocal.fetchRequest()
        request.predicate = NSPredicate(format: "address == %@ AND network.key == %@", address, networkKey)
        request.fetchLimit = 1
        request.relationshipKeyPathsForPrefetching = ["network"]
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("❌ Failed to find address: \(error)")
            return nil
        }
    }
    
    func findAddress(id: Int) -> AddressLocal? {
        let request = AddressLocal.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        request.relationshipKeyPathsForPrefetching = ["network"]
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("❌ Failed to find address by id: \(error)")
            return nil
        }
    }
    
    @discardableResult
    func createOrUpdateAddress(
        id: Int,
        address: String,
        label: String,
        networkKey: String,
        status: String = "created",
        isNotificationEnabled: Bool = false,
        isPendingSync: Bool = false,
        isLocalOnly: Bool = false,
        userID: Int? = nil
    ) -> AddressLocal {
        // Find or create the network first
        guard let networkLocal = findNetwork(key: networkKey) else {
            print("❌ Network not found for key: \(networkKey)")
            // Create a placeholder network if not found
            let placeholderNetwork = createOrUpdateNetwork(
                id: networkKey,
                key: networkKey,
                network: networkKey,
                label: networkKey,
                isActive: true,
                txLink: nil,
                accountLink: nil,
                isPendingSync: true
            )
            return createOrUpdateAddressWithNetwork(
                id: id,
                address: address,
                label: label,
                networkLocal: placeholderNetwork,
                status: status,
                isNotificationEnabled: isNotificationEnabled,
                isPendingSync: isPendingSync,
                isLocalOnly: isLocalOnly,
                userID: userID
            )
        }
        
        return createOrUpdateAddressWithNetwork(
            id: id,
            address: address,
            label: label,
            networkLocal: networkLocal,
            status: status,
            isNotificationEnabled: isNotificationEnabled,
            isPendingSync: isPendingSync,
            isLocalOnly: isLocalOnly,
            userID: userID
        )
    }
    
    @discardableResult
    private func createOrUpdateAddressWithNetwork(
        id: Int,
        address: String,
        label: String,
        networkLocal: NetworkLocal,
        status: String = "created",
        isNotificationEnabled: Bool = false,
        isPendingSync: Bool = false,
        isLocalOnly: Bool = false,
        userID: Int? = nil
    ) -> AddressLocal {
        // Priority for finding existing address:
        // 1. First try by address+network (most reliable for local-only addresses)
        // 2. Then by ID (for server-synced addresses)
        let existingByAddressNetwork = findAddress(address: address, networkLocal: networkLocal)
        let existingByID = id > 0 ? findAddress(id: id) : nil
        
        // If we find by address+network, prefer that (handles local-only -> server sync)
        let existingAddress = existingByAddressNetwork ?? existingByID
        
        let addressLocal = existingAddress ?? AddressLocal(context: viewContext)
        
        // Set/update properties
        addressLocal.id = Int64(id)
        addressLocal.address = address
        addressLocal.label = label
        addressLocal.network = networkLocal
        addressLocal.status = status
        addressLocal.isNotificationEnabled = isNotificationEnabled
        addressLocal.isPendingSync = isPendingSync
        addressLocal.isLocalOnly = isLocalOnly
        if let userID = userID {
            addressLocal.userID = Int64(userID)
        }
        
        if existingAddress == nil {
            addressLocal.createdAt = Date()
        }
        addressLocal.updatedAt = Date()
        
        save()
        return addressLocal
    }
    
    func deleteAddress(_ addressLocal: AddressLocal) {
        viewContext.delete(addressLocal)
        save()
    }
    
    func markAddressForSync(_ addressLocal: AddressLocal, isPending: Bool = true) {
        addressLocal.isPendingSync = isPending
        save()
    }
    
    /// Find all addresses with the same address string (across all networks)
    func findAddresses(byAddress address: String) -> [AddressLocal] {
        let request = AddressLocal.fetchRequest()
        request.predicate = NSPredicate(format: "address == %@", address)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AddressLocal.createdAt, ascending: false)]
        request.relationshipKeyPathsForPrefetching = ["network"]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("❌ Failed to find addresses by address string: \(error)")
            return []
        }
    }
    
    /// Update isLocalOnly property for an address
    func updateAddressLocalOnlyStatus(_ addressLocal: AddressLocal, isLocalOnly: Bool) {
        addressLocal.isLocalOnly = isLocalOnly
        save()
    }
    
    // MARK: - Network Operations
    
    func fetchNetworks() -> [NetworkLocal] {
        let request = NetworkLocal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NetworkLocal.label, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("❌ Failed to fetch networks: \(error)")
            return []
        }
    }
    
    func findNetwork(id: String) -> NetworkLocal? {
        let request = NetworkLocal.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("❌ Failed to find network by id: \(error)")
            return nil
        }
    }
    
    func findNetwork(key: String) -> NetworkLocal? {
        let request = NetworkLocal.fetchRequest()
        request.predicate = NSPredicate(format: "key == %@", key)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("❌ Failed to find network by key: \(error)")
            return nil
        }
    }
    
    @discardableResult
    func createOrUpdateNetwork(
        id: String,
        key: String,
        network: String,
        label: String?,
        isActive: Bool?,
        txLink: String?,
        accountLink: String?,
        isPendingSync: Bool = false
    ) -> NetworkLocal {
        // Try to find existing network by id first, then by key
        let existingNetwork = findNetwork(id: id) ?? findNetwork(key: key)
        
        let networkLocal = existingNetwork ?? NetworkLocal(context: viewContext)
        
        // Set/update properties
        networkLocal.id = id
        networkLocal.key = key
        networkLocal.network = network
        networkLocal.label = label
        networkLocal.isActive = isActive ?? true
        networkLocal.txLink = txLink
        networkLocal.accountLink = accountLink
        networkLocal.isPendingSync = isPendingSync
        
        save()
        return networkLocal
    }
    
    func deleteNetwork(_ networkLocal: NetworkLocal) {
        viewContext.delete(networkLocal)
        save()
    }
    
    // MARK: - Notification Operations
    
    func fetchNotifications() -> [NotificationLocal] {
        let request = NotificationLocal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NotificationLocal.createdAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("❌ Failed to fetch notifications: \(error)")
            return []
        }
    }
    
    func findNotification(id: Int) -> NotificationLocal? {
        let request = NotificationLocal.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("❌ Failed to find notification by id: \(error)")
            return nil
        }
    }
    
    func findNotification(eventID: String) -> NotificationLocal? {
        let request = NotificationLocal.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@", eventID)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("❌ Failed to find notification by eventID: \(error)")
            return nil
        }
    }
    
    @discardableResult
    func createOrUpdateNotification(
        id: Int,
        triggerAddress: String,
        targetAddress: String,
        preposition: String,
        network: String,
        value: String?,
        asset: String?,
        eventType: String,
        eventID: String,
        txHash: String?,
        createdAt: Date,
        isRead: Bool = false
    ) -> NotificationLocal {
        // Try to find existing notification by id first, then by eventID
        let existingNotification = findNotification(id: id) ?? findNotification(eventID: eventID)
        
        let notificationLocal = existingNotification ?? NotificationLocal(context: viewContext)
        
        // Set/update properties
        notificationLocal.id = Int64(id)
        notificationLocal.triggerAddress = triggerAddress
        notificationLocal.targetAddress = targetAddress
        notificationLocal.preposition = preposition
        notificationLocal.network = network
        notificationLocal.value = value
        notificationLocal.asset = asset
        notificationLocal.eventType = eventType
        notificationLocal.eventID = eventID
        notificationLocal.txHash = txHash
        notificationLocal.createdAt = createdAt
        notificationLocal.isRead = isRead
        
        save()
        return notificationLocal
    }
    
    func deleteNotification(_ notificationLocal: NotificationLocal) {
        viewContext.delete(notificationLocal)
        save()
    }
    
    func markNotificationAsRead(_ notificationLocal: NotificationLocal, isRead: Bool = true) {
        notificationLocal.isRead = isRead
        save()
    }
    
    // MARK: - Bulk Operations
    
    func deleteAllAddresses() {
        let request = AddressLocal.fetchRequest()
        
        do {
            let addresses = try viewContext.fetch(request)
            for address in addresses {
                viewContext.delete(address)
            }
            save()
        } catch {
            print("❌ Failed to delete all addresses: \(error)")
        }
    }
    
    func deleteAllNetworks() {
        let request = NetworkLocal.fetchRequest()
        
        do {
            let networks = try viewContext.fetch(request)
            for network in networks {
                viewContext.delete(network)
            }
            save()
        } catch {
            print("❌ Failed to delete all networks: \(error)")
        }
    }
    
    func deleteAllNotifications() {
        let request = NotificationLocal.fetchRequest()
        
        do {
            let notifications = try viewContext.fetch(request)
            for notification in notifications {
                viewContext.delete(notification)
            }
            save()
        } catch {
            print("❌ Failed to delete all notifications: \(error)")
        }
    }
    
    /// Wipe all local data (addresses, networks, notifications)
    /// Useful for clearing corrupted data or resetting the app
    func wipeAllData() {
        print("🗑️ Wiping all local data...")
        deleteAllAddresses()
        deleteAllNetworks()
        deleteAllNotifications()
        print("✅ All local data wiped")
    }
}
