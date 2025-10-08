//
//  WatchlistVM.swift
//  EthGasTracker
//
//  Created by Tem on 10/1/25.
//

import Foundation
import UIKit
import UserNotifications
import CoreData

let ADDRESS_LIMIT = 256

class WatchlistVM: ObservableObject {
    // Published local state from Core Data
    @Published var localAddresses: [AddressLocal] = []
    @Published var localNetworks: [NetworkLocal] = []
    @Published var notifications: [AddressTrackerAPIClient.Notification] = []
    @Published var isLoading = false
    @Published var isLoadingNotifications = false
    @Published var errorMessage: String?
    @Published var needsNotificationPermission = false
    @Published var hasMoreNotifications = false
    @Published var notificationCursor: Int = 0
    
    private var client: AddressTrackerAPIClient
    private let baseURL: String
    private let dataController: AddressTrackerDataController
    
    /// Initialize WatchlistVM with subscription-based user identification
    /// - Parameters:
    ///   - subscriptionIdentifier: The StoreKit original transaction ID (unique per user across devices). REQUIRED for address tracking.
    ///   - baseURL: The API base URL
    ///   - dataController: The Core Data controller
    init(subscriptionIdentifier: String, baseURL: String = "https://service.cryptofees.app", dataController: AddressTrackerDataController = .shared) {
        self.baseURL = baseURL
        self.dataController = dataController

        let config = AddressTrackerAPIClient.UserConfig(
            channel: "ios",
            channelUserID: subscriptionIdentifier
        )

        self.client = AddressTrackerAPIClient(
            baseURL: baseURL,
            userConfig: config
        )

        print("🔑 WatchlistVM initialized with Subscription ID: \(subscriptionIdentifier)")
        
        // Load local data from Core Data
        self.localAddresses = dataController.fetchAddresses()
        self.localNetworks = dataController.fetchNetworks()

        // Try to get device token if already available and notifications are enabled
        if let apnsDeviceToken = DeviceTokenManager.shared.deviceToken {
            Task {
                await updateUserWithAPNSTokenIfPermissionGranted(apnsDeviceToken)
            }
        }
    }
    
    // MARK: - Subscription Management
    
    /// Update the client with a new subscription identifier
    /// Call this when the subscription status changes
    func updateSubscriptionIdentifier(_ subscriptionIdentifier: String) {
        let config = AddressTrackerAPIClient.UserConfig(
            channel: "ios",
            channelUserID: subscriptionIdentifier
        )
        
        self.client = AddressTrackerAPIClient(
            baseURL: baseURL,
            userConfig: config
        )
        
        print("🔑 Updated to Subscription ID: \(subscriptionIdentifier)")
    }
    
    // MARK: - Local Data Management
    
    /// Load local data from Core Data
    @MainActor
    private func loadLocalData() {
        localAddresses = dataController.fetchAddresses()
        localNetworks = dataController.fetchNetworks()
    }
    
    /// Get addresses grouped by network key for UI convenience
    var addressesByNetwork: [String: [AddressLocal]] {
        Dictionary(grouping: localAddresses) { address in
            address.network?.key ?? "unknown"
        }
    }
    
    /// Get addresses for a specific network key
    func addresses(for networkKey: String) -> [AddressLocal] {
        localAddresses.filter { $0.network?.key == networkKey }
    }
    
    /// Get networks as a simple array of keys
    var networkKeys: [String] {
        localNetworks.compactMap { $0.key }
    }
    
    /// Get networks as a simple array of names
    var networkNames: [String] {
        localNetworks.compactMap { $0.network }
    }
    
    /// Update the user record with the APNS device token for push notifications
    /// Only updates if notification permissions are granted
    @MainActor
    private func updateUserWithAPNSTokenIfPermissionGranted(_ apnsDeviceToken: String) async {
        // Check if notification permissions are granted before updating
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        guard settings.authorizationStatus == .authorized || 
              settings.authorizationStatus == .provisional || 
              settings.authorizationStatus == .ephemeral else {
            print("ℹ️ Skipping APNS token update - notifications not enabled")
            return
        }
        
        print("📱 Updating user record with APNS device token: \(apnsDeviceToken)")

        do {
            let response = try await client.updateUser(apnsToken: apnsDeviceToken)
            print("✅ User updated successfully: \(response.status) - \(response.message)")

            if response.user != nil {
                print("✅ User info updated successfully")
            }
        } catch {
            print("❌ Failed to update user with device token: \(error.localizedDescription)")
        }
    }
    
    /// Update the user record with the APNS device token for push notifications
    /// This version assumes permissions have already been checked
    @MainActor
    private func updateUserWithAPNSToken(_ apnsDeviceToken: String) async {
        print("📱 Updating user record with APNS device token: \(apnsDeviceToken)")

        do {
            let response = try await client.updateUser(apnsToken: apnsDeviceToken)
            print("✅ User updated successfully: \(response.status) - \(response.message)")

            if response.user != nil {
                print("✅ User info updated successfully")
            }
        } catch {
            print("❌ Failed to update user with device token: \(error.localizedDescription)")
        }
    }
    
    /// Ensure notification permissions and device token are available
    @MainActor
    func ensureNotificationSetup() async -> Bool {
        // Check current authorization status
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            print("✅ Notification permissions already granted")
            // Register for remote notifications if not already done
            await registerForRemoteNotifications()
            // Update user with device token if available
            if let apnsDeviceToken = DeviceTokenManager.shared.deviceToken {
                await updateUserWithAPNSToken(apnsDeviceToken)
            }
            return true
            
        case .denied:
            print("❌ Notification permissions denied")
            needsNotificationPermission = true
            errorMessage = "Push notifications are required to receive alerts. Please enable notifications in Settings."
            return false
            
        case .notDetermined:
            print("🔔 Requesting notification permissions...")
            return await requestNotificationPermission()
            
        case .ephemeral:
            await registerForRemoteNotifications()
            // Update user with device token if available
            if let apnsDeviceToken = DeviceTokenManager.shared.deviceToken {
                await updateUserWithAPNSToken(apnsDeviceToken)
            }
            return true
            
        @unknown default:
            return false
        }
    }
    
    /// Request notification permission from the user
    @MainActor
    private func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            
            if granted {
                print("✅ Notification permission granted")
                await registerForRemoteNotifications()
                // Update user with device token after successful registration
                if let apnsDeviceToken = DeviceTokenManager.shared.deviceToken {
                    await updateUserWithAPNSToken(apnsDeviceToken)
                }
                return true
            } else {
                print("❌ Notification permission denied by user")
                needsNotificationPermission = true
                errorMessage = "Push notifications are required to receive alerts."
                return false
            }
        } catch {
            print("❌ Error requesting notification permission: \(error)")
            errorMessage = "Failed to request notification permissions: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Register for remote notifications and wait for device token
    @MainActor
    private func registerForRemoteNotifications() async {
        // Register for remote notifications on main thread
        UIApplication.shared.registerForRemoteNotifications()
        
        // Wait a bit for the device token to be received (if not already available)
        if DeviceTokenManager.shared.deviceToken == nil {
            print("⏳ Waiting for device token...")
            // Wait up to 3 seconds for device token
            for _ in 0..<30 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                if let apnsDeviceToken = DeviceTokenManager.shared.deviceToken {
                    await updateUserWithAPNSToken(apnsDeviceToken)
                    print("✅ Device token received and user updated")
                    return
                }
            }
            print("⚠️ Device token not received within timeout")
        } else if let apnsDeviceToken = DeviceTokenManager.shared.deviceToken {
            await updateUserWithAPNSToken(apnsDeviceToken)
            print("✅ Using existing device token")
        }
    }
    
    @MainActor
    func loadAddresses() async {
        // Ensure we have the device token before loading addresses
        await ensureDeviceTokenUpdated()
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch from API
            let apiAddresses = try await client.listAddresses()
            
            // Sync API data to Core Data
            for (networkKey, addressList) in apiAddresses {
                for apiAddress in addressList {
                dataController.createOrUpdateAddress(
                    id: apiAddress.id,
                    address: apiAddress.address,
                    label: apiAddress.label,
                    networkKey: networkKey,
                    status: apiAddress.status,
                    isNotificationEnabled: apiAddress.isNotificationsEnabled,
                    isPendingSync: false,
                    isLocalOnly: false,
                    userID: apiAddress.userID
                )
                }
            }
            
            // Reload local data
            loadLocalData()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadNetworks() async {
        do {
            // Fetch from API
            let apiNetworks = try await client.getAvailableNetworks()
            
            // Sync API data to Core Data
            for network in apiNetworks {
                dataController.createOrUpdateNetwork(
                    id: network.id,
                    key: network.key,
                    network: network.network,
                    label: network.label,
                    isActive: network.isActive,
                    txLink: network.txLink,
                    accountLink: network.accountLink,
                    isPendingSync: false
                )
            }
            
            // Reload local data
            loadLocalData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Ensure the user record is updated with the device token (if available) without requesting permissions
    @MainActor
    private func ensureDeviceTokenUpdated() async {
        // Check if notification permissions are already granted
        let settings = await UNUserNotificationCenter.current().notificationSettings()

        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional || settings.authorizationStatus == .ephemeral {
            // Check if device token is already available
            if let apnsDeviceToken = DeviceTokenManager.shared.deviceToken {
                await updateUserWithAPNSToken(apnsDeviceToken)
                print("✅ Using existing device token for user record update")
                return
            }

            print("🔄 Permissions granted, registering for remote notifications...")
            // Permissions already granted, just register for notifications
            UIApplication.shared.registerForRemoteNotifications()

            // Wait briefly for device token
            for _ in 0..<30 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                if let apnsDeviceToken = DeviceTokenManager.shared.deviceToken {
                    await updateUserWithAPNSToken(apnsDeviceToken)
                    print("✅ Device token received and user record updated")
                    return
                }
            }
            print("⚠️ Device token not received, using vendor ID as fallback")
        } else {
            print("ℹ️ Notification permissions not granted yet, using vendor ID as fallback")
        }
    }
    
    @MainActor
    func addAddress(_ address: String, label: String, network: String) async {
        isLoading = true
        errorMessage = nil
        
        // Check if address limit is reached
        if localAddresses.count >= ADDRESS_LIMIT {
            errorMessage = "Address limit reached. You can track up to \(ADDRESS_LIMIT) addresses."
            isLoading = false
            return
        }
        
        // Check if address already exists on this network
        if dataController.findAddress(address: address, networkKey: network) != nil {
            errorMessage = "This address is already being tracked on \(network)"
            isLoading = false
            return
        }
        
        // Optimistic update: Add to local cache immediately with temporary ID and isPendingSync = true
        // Use a temporary negative ID for optimistic updates (will be replaced with real ID from server)
        let tempId = -Int(Date().timeIntervalSince1970 * 1000)
        let localAddress = dataController.createOrUpdateAddress(
            id: tempId,
            address: address,
            label: label,
            networkKey: network,
            status: "pending",
            isNotificationEnabled: false,
            isPendingSync: true,
            isLocalOnly: false
        )
        loadLocalData()
        
        do {
            let input = AddressTrackerAPIClient.AddressInput(
                address: address,
                label: label
            )
            let response = try await client.addAddresses([network: [input]])
            
            // Sync successful: update with server data
            if let serverAddress = response.addresses.first {
                // Delete the temporary optimistic entry
                dataController.deleteAddress(localAddress)
                
                // Create new entry with real server ID
                dataController.createOrUpdateAddress(
                    id: serverAddress.id,
                    address: serverAddress.address,
                    label: serverAddress.label,
                    networkKey: network,
                    status: serverAddress.status,
                    isNotificationEnabled: serverAddress.isNotificationsEnabled,
                    isPendingSync: false,
                    isLocalOnly: false,
                    userID: serverAddress.userID
                )
            } else {
                // Mark as synced even if no address returned
                dataController.markAddressForSync(localAddress, isPending: false)
            }
            
            loadLocalData()
        } catch {
            // Sync failed: keep isPendingSync = true
            errorMessage = error.localizedDescription
            print("❌ Failed to add address to server, keeping as pending sync")
        }
        
        isLoading = false
    }
    
    @MainActor
    func addAddressToNetworks(_ address: String, label: String, networks: Set<String>) async {
        isLoading = true
        errorMessage = nil
        
        // Check for duplicate addresses on selected networks
        var existingNetworks: [String] = []
        for networkKey in networks {
            if dataController.findAddress(address: address, networkKey: networkKey) != nil {
                existingNetworks.append(networkKey)
            }
        }
        
        if !existingNetworks.isEmpty {
            let networkList = existingNetworks.joined(separator: ", ")
            errorMessage = "This address is already being tracked on: \(networkList)"
            isLoading = false
            return
        }
        
        // Check if adding these addresses would exceed the limit
        let newAddressCount = networks.count
        if localAddresses.count + newAddressCount > ADDRESS_LIMIT {
            errorMessage = "Address limit exceeded. You can track up to \(ADDRESS_LIMIT) addresses. Adding \(newAddressCount) would exceed this limit."
            isLoading = false
            return
        }
        
        // Optimistic update: Add to local cache for all networks with temporary IDs and isPendingSync = true
        var localAddresses: [AddressLocal] = []
        for networkKey in networks {
            let tempId = -Int(Date().timeIntervalSince1970 * 1000) - localAddresses.count
            let localAddress = dataController.createOrUpdateAddress(
                id: tempId,
                address: address,
                label: label,
                networkKey: networkKey,
                status: "pending",
                isNotificationEnabled: false,
                isPendingSync: true,
                isLocalOnly: false
            )
            localAddresses.append(localAddress)
        }
        loadLocalData()
        
        do {
            let input = AddressTrackerAPIClient.AddressInput(
                address: address,
                label: label
            )
            // Create a dictionary with all networks pointing to the same address
            var networkMap: [String: [AddressTrackerAPIClient.AddressInput]] = [:]
            for network in networks {
                networkMap[network] = [input]
            }
            let response = try await client.addAddresses(networkMap)
            
            // Sync successful: delete temporary entries and create new ones with real server IDs
            for tempAddress in localAddresses {
                dataController.deleteAddress(tempAddress)
            }
            
            for serverAddress in response.addresses {
                dataController.createOrUpdateAddress(
                    id: serverAddress.id,
                    address: serverAddress.address,
                    label: serverAddress.label,
                    networkKey: serverAddress.network,
                    status: serverAddress.status,
                    isNotificationEnabled: serverAddress.isNotificationsEnabled,
                    isPendingSync: false,
                    isLocalOnly: false,
                    userID: serverAddress.userID
                )
            }
            
            loadLocalData()
        } catch {
            // Sync failed: keep isPendingSync = true for all
            errorMessage = error.localizedDescription
            print("❌ Failed to add addresses to server, keeping as pending sync")
        }
        
        isLoading = false
    }
    
    @MainActor
    func removeAddress(_ address: String, network: String) async {
        isLoading = true
        errorMessage = nil
        
        // Optimistic update: Remove from local cache immediately
        if let localAddress = dataController.findAddress(address: address, networkKey: network) {
            dataController.deleteAddress(localAddress)
            loadLocalData()
        }
        
        do {
            _ = try await client.removeAddresses([network: [address]])
            // Sync successful, already removed from local cache
        } catch {
            // Sync failed: restore the address
            errorMessage = error.localizedDescription
            print("❌ Failed to remove address from server, restoring locally")
            // Re-add the address with temporary ID and isPendingSync = true to indicate it needs deletion
            let tempId = -Int(Date().timeIntervalSince1970 * 1000)
            dataController.createOrUpdateAddress(
                id: tempId,
                address: address,
                label: "", // We don't have the label anymore
                networkKey: network,
                status: "pending_delete",
                isPendingSync: true,
                isLocalOnly: false
            )
            loadLocalData()
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateLabel(addressId: Int, address: String, network: String, newLabel: String) async {
        isLoading = true
        errorMessage = nil
        
        // Optimistic update: Update label in local cache immediately
        if let localAddress = dataController.findAddress(address: address, networkKey: network) {
            let oldLabel = localAddress.label
            localAddress.label = newLabel
            localAddress.isPendingSync = true
            dataController.save()
            loadLocalData()
            
            do {
                _ = try await client.updateAddressLabel(
                    addressId: addressId,
                    oldAddress: address,
                    network: network,
                    newLabel: newLabel
                )
                // Sync successful: mark as synced
                localAddress.isPendingSync = false
                dataController.save()
                loadLocalData()
            } catch {
                // Sync failed: revert label
                errorMessage = error.localizedDescription
                print("❌ Failed to update label on server, reverting")
                localAddress.label = oldLabel
                localAddress.isPendingSync = true
                dataController.save()
                loadLocalData()
            }
        } else {
            errorMessage = "Address not found in local cache"
        }
        
        isLoading = false
    }
    
    @MainActor
    func toggleNotifications(address: String, network: String, enabled: Bool) async {
        errorMessage = nil
        
        // If enabling notifications, ensure permissions are granted first
        if enabled {
            let notificationReady = await ensureNotificationSetup()
            
            if !notificationReady {
                // Error message is already set by ensureNotificationSetup
                return
            }
        }
        
        // Optimistic update: Toggle notification status in local cache immediately
        if let localAddress = dataController.findAddress(address: address, networkKey: network) {
            let oldNotificationStatus = localAddress.isNotificationEnabled
            localAddress.isNotificationEnabled = enabled
            localAddress.isPendingSync = true
            dataController.save()
            loadLocalData()
            
            do {
                _ = try await client.updateNotifications([network: [address]], enabled: enabled)
                // Sync successful: mark as synced
                localAddress.isPendingSync = false
                dataController.save()
                loadLocalData()
            } catch {
                // Sync failed: revert notification status
                errorMessage = error.localizedDescription
                print("❌ Failed to update notifications on server, reverting")
                localAddress.isNotificationEnabled = oldNotificationStatus
                localAddress.isPendingSync = true
                dataController.save()
                loadLocalData()
            }
        } else {
            errorMessage = "Address not found in local cache"
        }
    }
    
    /// Load notifications for the user (first page)
    @MainActor
    func loadNotifications() async {
        isLoadingNotifications = true
        errorMessage = nil
        
        do {
            let response = try await client.listNotifications(limit: 20, cursor: 0)
            notifications = response.notifications
            hasMoreNotifications = response.pagination.hasMore
            notificationCursor = response.pagination.nextCursor ?? 0
            print("✅ Loaded \(response.count) notifications")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load notifications: \(error.localizedDescription)")
        }
        
        isLoadingNotifications = false
    }
    
    /// Load more notifications (next page) for infinite scroll
    @MainActor
    func loadMoreNotifications() async {
        guard hasMoreNotifications && !isLoadingNotifications else {
            return
        }
        
        isLoadingNotifications = true
        
        do {
            let response = try await client.listNotifications(limit: 20, cursor: notificationCursor)
            notifications.append(contentsOf: response.notifications)
            hasMoreNotifications = response.pagination.hasMore
            notificationCursor = response.pagination.nextCursor ?? 0
            print("✅ Loaded \(response.count) more notifications (total: \(notifications.count))")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load more notifications: \(error.localizedDescription)")
        }
        
        isLoadingNotifications = false
    }
    
    /// Refresh notifications (reload from first page)
    @MainActor
    func refreshNotifications() async {
        await loadNotifications()
    }
    
    // MARK: - Toggle Tracking (Local-Only Mode)
    
    /// Toggle tracking for an address (works across all networks with the same address)
    /// When tracking is OFF: calls /untrack API but keeps the address in local DB with isLocalOnly = true
    /// When tracking is ON: calls /track API and sets isLocalOnly = false
    /// - Parameters:
    ///   - address: The address string
    ///   - enabled: True to enable tracking (call /track), False to disable tracking (call /untrack)
    @MainActor
    func toggleTracking(address: String, enabled: Bool) async {
        isLoading = true
        errorMessage = nil
        
        // Find all addresses with this address string (across all networks)
        let addressesToToggle = dataController.findAddresses(byAddress: address)
        
        if addressesToToggle.isEmpty {
            errorMessage = "Address not found"
            isLoading = false
            return
        }
        
        // Build network map for API call
        var networkMap: [String: [String]] = [:]
        for addressLocal in addressesToToggle {
            guard let networkKey = addressLocal.network?.key else { continue }
            
            if networkMap[networkKey] == nil {
                networkMap[networkKey] = []
            }
            networkMap[networkKey]?.append(addressLocal.address ?? "")
        }
        
        if enabled {
            // ENABLE TRACKING: Call /track API
            await enableTracking(addresses: addressesToToggle, networkMap: networkMap)
        } else {
            // DISABLE TRACKING: Call /untrack API but keep in local DB
            await disableTracking(addresses: addressesToToggle, networkMap: networkMap)
        }
        
        isLoading = false
    }
    
    /// Enable tracking for addresses (call /track API and set isLocalOnly = false)
    @MainActor
    private func enableTracking(addresses: [AddressLocal], networkMap: [String: [String]]) async {
        // Optimistically update isLocalOnly to false
        for addressLocal in addresses {
            dataController.updateAddressLocalOnlyStatus(addressLocal, isLocalOnly: false)
            addressLocal.isPendingSync = true
        }
        dataController.save()
        loadLocalData()
        
        do {
            // Build AddressInput map for tracking
            var trackingMap: [String: [AddressTrackerAPIClient.AddressInput]] = [:]
            for (networkKey, addressStrings) in networkMap {
                trackingMap[networkKey] = addressStrings.map { addressString in
                    // Find the local address to get its label
                    let localAddress = addresses.first { $0.address == addressString && $0.network?.key == networkKey }
                    let label = localAddress?.label ?? addressString
                    return AddressTrackerAPIClient.AddressInput(address: addressString, label: label)
                }
            }
            
            let response = try await client.addAddresses(trackingMap)
            
            // Update with server data (new IDs)
            for serverAddress in response.addresses {
                dataController.createOrUpdateAddress(
                    id: serverAddress.id,
                    address: serverAddress.address,
                    label: serverAddress.label,
                    networkKey: serverAddress.network,
                    status: serverAddress.status,
                    isNotificationEnabled: serverAddress.isNotificationsEnabled,
                    isPendingSync: false,
                    isLocalOnly: false,
                    userID: serverAddress.userID
                )
            }
            
            loadLocalData()
            print("✅ Tracking enabled for \(addresses.count) addresses")
        } catch {
            // Revert on failure
            errorMessage = error.localizedDescription
            for addressLocal in addresses {
                dataController.updateAddressLocalOnlyStatus(addressLocal, isLocalOnly: true)
                addressLocal.isPendingSync = false
            }
            dataController.save()
            loadLocalData()
            print("❌ Failed to enable tracking, reverting to local-only")
        }
    }
    
    /// Disable tracking for addresses (call /untrack API but keep in local DB with isLocalOnly = true)
    @MainActor
    private func disableTracking(addresses: [AddressLocal], networkMap: [String: [String]]) async {
        // Store old status for rollback
        let oldStatuses = addresses.map { ($0, $0.isLocalOnly) }
        
        // Optimistically update isLocalOnly to true
        for addressLocal in addresses {
            dataController.updateAddressLocalOnlyStatus(addressLocal, isLocalOnly: true)
            addressLocal.isPendingSync = true
        }
        dataController.save()
        loadLocalData()
        
        do {
            _ = try await client.removeAddresses(networkMap)
            
            // Mark as synced
            for addressLocal in addresses {
                addressLocal.isPendingSync = false
            }
            dataController.save()
            loadLocalData()
            print("✅ Tracking disabled for \(addresses.count) addresses (kept in local DB)")
        } catch {
            // Revert on failure
            errorMessage = error.localizedDescription
            for (addressLocal, oldIsLocalOnly) in oldStatuses {
                dataController.updateAddressLocalOnlyStatus(addressLocal, isLocalOnly: oldIsLocalOnly)
                addressLocal.isPendingSync = false
            }
            dataController.save()
            loadLocalData()
            print("❌ Failed to disable tracking, reverting")
        }
    }
}

