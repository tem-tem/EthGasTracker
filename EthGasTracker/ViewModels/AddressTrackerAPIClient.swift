//
//  AddressTrackerAPIClient.swift
//  EthGasTracker
//
//  Created by Tem on 10/1/25.
//


import Foundation

// MARK: - API Client
/// API client for communicating with the Address Tracker REST API
/// Supports tracking, untracking, listing addresses, and managing networks
@available(iOS 13.0, *)
public class AddressTrackerAPIClient {
    
    // MARK: - Properties
    private let baseURL: String
    private let session: URLSession
    
    // MARK: - User Configuration
    /// User identification for API calls
    /// - Important: For iOS channel, `channelUserID` MUST be the APNS device token (hexadecimal string),
    ///   not the device vendor ID. This token is used by the backend to send push notifications.
    public struct UserConfig {
        let channel: String
        /// User identifier for the channel
        /// - For iOS: This should be the APNS device token (received from `didRegisterForRemoteNotificationsWithDeviceToken`)
        /// - For other channels: Use the appropriate channel-specific user ID
        let channelUserID: String
        
        public init(channel: String, channelUserID: String) {
            self.channel = channel
            self.channelUserID = channelUserID
        }
    }
    
    private let userConfig: UserConfig
    
    // MARK: - Initialization
    public init(baseURL: String, userConfig: UserConfig, session: URLSession = .shared) {
        // Ensure baseURL doesn't end with a slash
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        self.userConfig = userConfig
        self.session = session
    }
    
    // MARK: - Models
    
    /// Address model
    public struct Address: Codable, Identifiable {
        public let id: Int
        public let address: String
        public let label: String
        public let network: String
        public let userID: Int?
        public let status: String
        public let isNotificationsEnabled: Bool
        public let createdAt: String?
        public let updatedAt: String?
        
        enum CodingKeys: String, CodingKey {
            case id, address, label, network, status
            case userID = "user_id"
            case isNotificationsEnabled = "is_notifications_enabled"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
        
        public init(id: Int, address: String, label: String, network: String, userID: Int? = nil, status: String = "created", isNotificationsEnabled: Bool = false, createdAt: String? = nil, updatedAt: String? = nil) {
            self.id = id
            self.address = address
            self.label = label
            self.network = network
            self.userID = userID
            self.status = status
            self.isNotificationsEnabled = isNotificationsEnabled
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
    
    /// Address input for adding new addresses
    public struct AddressInput: Codable {
        public let address: String
        public let label: String
        
        public init(address: String, label: String? = nil) {
            self.address = address
            self.label = label ?? address
        }
    }
    
    /// Network/Chain information
    public struct Network: Codable, Identifiable {
        public let id: String
        public let key: String
        public let network: String
        public let label: String?
        public let isActive: Bool?
        public let txLink: String?
        public let accountLink: String?
        
        enum CodingKeys: String, CodingKey {
            case id, network, label, key
            case isActive = "is_active"
            case txLink = "tx_link"
            case accountLink = "account_link"
        }
        
        public init(id: String, key: String, network: String, label: String, isActive: Bool? = nil, txLink: String? = nil, accountLink: String? = nil) {
            self.id = id
            self.key = key
            self.network = network
            self.label = label
            self.isActive = isActive
            self.txLink = txLink
            self.accountLink = accountLink
        }
    }
    
    /// User model
    public struct User: Codable {
        public let id: Int
        public let channel: String
        public let channelUserID: String
        public let createdAt: String
        public let updatedAt: String
        
        enum CodingKeys: String, CodingKey {
            case id, channel
            case channelUserID = "channel_user_id"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
    }
    
    /// Notification model
    public struct Notification: Codable, Identifiable {
        public let id: Int
        public let userID: String
        public let channel: String
        public let triggerAddress: String
        public let targetAddress: String
        public let preposition: String
        public let network: String
        public let value: String?
        public let asset: String?
        public let eventType: String
        public let eventID: String
        public let txHash: String?
        public let processed: Bool
        public let sizeInBytes: Int
        public let createdAt: String
        public let processedAt: String?
        
        enum CodingKeys: String, CodingKey {
            case id, channel, network, value, asset, processed
            case userID = "user_id"
            case triggerAddress = "trigger_address"
            case targetAddress = "target_address"
            case preposition
            case eventType = "event_type"
            case eventID = "event_id"
            case txHash = "tx_hash"
            case sizeInBytes = "size_in_bytes"
            case createdAt = "created_at"
            case processedAt = "processed_at"
        }
    }
    
    /// Pagination info for notifications
    public struct PaginationInfo: Codable {
        public let limit: Int
        public let cursor: Int
        public let hasMore: Bool
        public let nextCursor: Int?
        
        enum CodingKeys: String, CodingKey {
            case limit, cursor
            case hasMore = "has_more"
            case nextCursor = "next_cursor"
        }
    }
    
    // MARK: - Request/Response Models
    
    private struct TrackAddressRequest: Codable {
        let networkMap: [String: [AddressInput]]
        let user: UserInfo
        
        enum CodingKeys: String, CodingKey {
            case networkMap = "network_map"
            case user
        }
    }
    
    private struct UntrackAddressRequest: Codable {
        let networkMap: [String: [String]]
        let user: UserInfo
        
        enum CodingKeys: String, CodingKey {
            case networkMap = "network_map"
            case user
        }
    }
    
    private struct UpdateNotificationsRequest: Codable {
        let networkMap: [String: [String]]
        let enabled: Bool
        let user: UserInfo

        enum CodingKeys: String, CodingKey {
            case networkMap = "network_map"
            case enabled
            case user
        }
    }

    private struct UpdateUserRequest: Codable {
        let user: UpdateUserInfo

        enum CodingKeys: String, CodingKey {
            case user
        }
    }

    private struct UpdateUserInfo: Codable {
        let channel: String
        let channelUserID: String
        let apnsToken: String?

        enum CodingKeys: String, CodingKey {
            case channel
            case channelUserID = "channel_user_id"
            case apnsToken = "apns_token"
        }
    }
    
    private struct ListAddressesRequest: Codable {
        let channel: String
        let channelUserID: String
        
        enum CodingKeys: String, CodingKey {
            case channel
            case channelUserID = "channel_user_id"
        }
    }
    
    public struct UserInfo: Codable {
        public let channel: String
        public let channelUserID: String
        
        enum CodingKeys: String, CodingKey {
            case channel
            case channelUserID = "channel_user_id"
        }
    }
    
    public struct TrackResponse: Codable {
        public let status: String
        public let message: String?
        public let addresses: [Address]
        public let validationFailed: [String: [String: Bool]]?
        public let failedAddresses: [AddressError]?
        public let webhookErrors: [String]?
        
        enum CodingKeys: String, CodingKey {
            case status, message, addresses
            case validationFailed = "validation_failed"
            case failedAddresses = "failed_addresses"
            case webhookErrors = "webhook_errors"
        }
    }
    
    public struct AddressError: Codable {
        public let address: String
        public let error: String
    }
    
    public struct UntrackResponse: Codable {
        public let status: String
        public let message: String
        public let deletedAddresses: [String: [String]]
        public let notFound: [String: [String]]
        
        enum CodingKeys: String, CodingKey {
            case status, message
            case deletedAddresses = "deleted_addresses"
            case notFound = "not_found"
        }
    }
    
    public struct ListAddressesResponse: Codable {
        public let status: String
        public let message: String
        public let user: User?
        public let networkAddresses: [String: [[String: AnyCodable]]]
        
        enum CodingKeys: String, CodingKey {
            case status, message, user
            case networkAddresses = "network_addresses"
        }
    }
    
    public struct NetworksResponse: Codable {
        public let status: String
        public let message: String?
        public let webhooks: [Network]
    }
    
    public struct UpdateNotificationsResponse: Codable {
        public let status: String
        public let message: String
        public let enabled: Bool
        public let updatedCount: Int
        public let updatedAddresses: [String: [String]]?
        public let notFound: [String: [String]]?

        enum CodingKeys: String, CodingKey {
            case status, message, enabled
            case updatedCount = "updated_count"
            case updatedAddresses = "updated_addresses"
            case notFound = "not_found"
        }
    }

    public struct UpdateUserResponse: Codable {
        public let status: String
        public let message: String
        public let user: UserInfo?

        enum CodingKeys: String, CodingKey {
            case status, message, user
        }
    }
    
    public struct ListNotificationsResponse: Codable {
        public let status: String
        public let message: String
        public let count: Int
        public let notifications: [Notification]
        public let pagination: PaginationInfo
        
        enum CodingKeys: String, CodingKey {
            case status, message, count, notifications, pagination
        }
    }
    
    public struct ErrorResponse: Codable {
        public let status: String
        public let message: String
        public let error: String?
        public let details: String?
    }
    
    // MARK: - API Methods
    
    /// Add addresses to watchlist (supports bulk operations)
    /// - Parameters:
    ///   - addresses: Dictionary mapping network names to arrays of address inputs
    ///   - completion: Completion handler with result
    public func addAddresses(
        _ addresses: [String: [AddressInput]],
        completion: @escaping (Result<TrackResponse, Error>) -> Void
    ) {
        let endpoint = "/api/v1/track"
        let url = URL(string: baseURL + endpoint)!
        
        let requestBody = TrackAddressRequest(
            networkMap: addresses,
            user: UserInfo(
                channel: userConfig.channel,
                channelUserID: userConfig.channelUserID
            )
        )
        
        print("📡 API Request - Channel: \(userConfig.channel), UserID: \(userConfig.channelUserID)")
        
        performRequest(url: url, method: "POST", body: requestBody, completion: completion)
    }
    
    /// Remove addresses from watchlist (supports bulk operations)
    /// - Parameters:
    ///   - addresses: Dictionary mapping network names to arrays of address strings
    ///   - completion: Completion handler with result
    public func removeAddresses(
        _ addresses: [String: [String]],
        completion: @escaping (Result<UntrackResponse, Error>) -> Void
    ) {
        let endpoint = "/api/v1/untrack"
        let url = URL(string: baseURL + endpoint)!
        
        let requestBody = UntrackAddressRequest(
            networkMap: addresses,
            user: UserInfo(
                channel: userConfig.channel,
                channelUserID: userConfig.channelUserID
            )
        )
        
        performRequest(url: url, method: "POST", body: requestBody, completion: completion)
    }
    
    /// List all addresses for the current user
    /// - Parameter completion: Completion handler with addresses grouped by network
    public func listAddresses(
        completion: @escaping (Result<[String: [Address]], Error>) -> Void
    ) {
        let endpoint = "/api/v1/list"
        let url = URL(string: baseURL + endpoint)!
        
        let requestBody = ListAddressesRequest(
            channel: userConfig.channel,
            channelUserID: userConfig.channelUserID
        )

        print("📡 API Request - Channel: \(userConfig.channel), UserID: \(userConfig.channelUserID)")
        
        performRequest(url: url, method: "POST", body: requestBody) { (result: Result<ListAddressesResponse, Error>) in
            switch result {
            case .success(let response):
                // Convert response to grouped addresses
                var groupedAddresses: [String: [Address]] = [:]
                
                for (network, addressesData) in response.networkAddresses {
                    let addresses = addressesData.compactMap { addressData -> Address? in
                        guard let id = addressData["id"]?.intValue,
                              let address = addressData["address"]?.stringValue,
                              let label = addressData["label"]?.stringValue,
                              let status = addressData["status"]?.stringValue else {
                            return nil
                        }
                        
                        // Parse is_notifications_enabled with default false
                        let isNotificationsEnabled = addressData["is_notifications_enabled"]?.boolValue ?? false
                        print("addressData: \(addressData)")
                        return Address(
                            id: id,
                            address: address,
                            label: label,
                            network: network,
                            status: status,
                            isNotificationsEnabled: isNotificationsEnabled
                        )
                    }
                    groupedAddresses[network] = addresses
                }
                
                completion(.success(groupedAddresses))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Get available blockchain networks/chains
    /// - Parameter completion: Completion handler with list of networks
    public func getAvailableNetworks(
        completion: @escaping (Result<[Network], Error>) -> Void
    ) {
        let endpoint = "/api/v1/webhooks"
        let url = URL(string: baseURL + endpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let response = try JSONDecoder().decode(NetworksResponse.self, from: data)
                    completion(.success(response.webhooks))
                } catch {
                    completion(.failure(error))
                }
            } else {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    completion(.failure(APIError.serverError(errorResponse.message)))
                } else {
                    completion(.failure(APIError.httpError(httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    /// Update notifications settings for addresses
    /// - Parameters:
    ///   - addresses: Dictionary mapping network names to arrays of address strings
    ///   - enabled: Whether to enable or disable notifications
    ///   - completion: Completion handler with result
    public func updateNotifications(
        _ addresses: [String: [String]],
        enabled: Bool,
        completion: @escaping (Result<UpdateNotificationsResponse, Error>) -> Void
    ) {
        let endpoint = "/api/v1/notifications/update"
        let url = URL(string: baseURL + endpoint)!
        
        let requestBody = UpdateNotificationsRequest(
            networkMap: addresses,
            enabled: enabled,
            user: UserInfo(
                channel: userConfig.channel,
                channelUserID: userConfig.channelUserID
            )
        )
        
        performRequest(url: url, method: "POST", body: requestBody, completion: completion)
    }
    
    /// Update label for a single address
    /// Note: This is a convenience method that removes and re-adds the address with a new label
    /// - Parameters:
    ///   - addressId: The address ID (not used in current implementation)
    ///   - oldAddress: The address string
    ///   - network: The network/chain name
    ///   - newLabel: The new label
    ///   - completion: Completion handler
    public func updateAddressLabel(
        addressId: Int,
        oldAddress: String,
        network: String,
        newLabel: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        // First, remove the address
        removeAddresses([network: [oldAddress]]) { [weak self] removeResult in
            switch removeResult {
            case .success(_):
                // Then add it back with new label
                let addressInput = AddressInput(address: oldAddress, label: newLabel)
                self?.addAddresses([network: [addressInput]]) { addResult in
                    switch addResult {
                    case .success(_):
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Update labels for multiple addresses in bulk
    /// - Parameters:
    ///   - updates: Dictionary mapping network to array of (address, newLabel) tuples
    ///   - completion: Completion handler
    public func updateAddressLabelsBulk(
        _ updates: [String: [(address: String, newLabel: String)]],
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        // Prepare addresses to remove
        var addressesToRemove: [String: [String]] = [:]
        var addressesToAdd: [String: [AddressInput]] = [:]
        
        for (network, items) in updates {
            addressesToRemove[network] = items.map { $0.address }
            addressesToAdd[network] = items.map { AddressInput(address: $0.address, label: $0.newLabel) }
        }
        
        // Remove old addresses
        removeAddresses(addressesToRemove) { [weak self] removeResult in
            switch removeResult {
            case .success(_):
                // Add back with new labels
                self?.addAddresses(addressesToAdd) { addResult in
                    switch addResult {
                    case .success(_):
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Async/Await Methods (iOS 15+)
    
    #if compiler(>=5.5)
    @available(iOS 15.0, *)
    public func addAddresses(_ addresses: [String: [AddressInput]]) async throws -> TrackResponse {
        try await withCheckedThrowingContinuation { continuation in
            addAddresses(addresses) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func removeAddresses(_ addresses: [String: [String]]) async throws -> UntrackResponse {
        try await withCheckedThrowingContinuation { continuation in
            removeAddresses(addresses) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func listAddresses() async throws -> [String: [Address]] {
        try await withCheckedThrowingContinuation { continuation in
            listAddresses { result in
                continuation.resume(with: result)
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func getAvailableNetworks() async throws -> [Network] {
        try await withCheckedThrowingContinuation { continuation in
            getAvailableNetworks { result in
                continuation.resume(with: result)
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func updateAddressLabel(
        addressId: Int,
        oldAddress: String,
        network: String,
        newLabel: String
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            updateAddressLabel(
                addressId: addressId,
                oldAddress: oldAddress,
                network: network,
                newLabel: newLabel
            ) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func updateAddressLabelsBulk(
        _ updates: [String: [(address: String, newLabel: String)]]
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            updateAddressLabelsBulk(updates) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func updateNotifications(
        _ addresses: [String: [String]],
        enabled: Bool
    ) async throws -> UpdateNotificationsResponse {
        try await withCheckedThrowingContinuation { continuation in
            updateNotifications(addresses, enabled: enabled) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Update user information (e.g., APNS token for iOS notifications)
    /// - Parameters:
    ///   - apnsToken: The APNS device token (optional)
    ///   - completion: Completion handler
    public func updateUser(apnsToken: String? = nil, completion: @escaping (Result<UpdateUserResponse, Error>) -> Void) {
        let endpoint = "/api/v1/user"
        let url = URL(string: baseURL + endpoint)!

        let requestBody = UpdateUserRequest(
            user: UpdateUserInfo(
                channel: userConfig.channel,
                channelUserID: userConfig.channelUserID,
                apnsToken: apnsToken
            )
        )

        performRequest(url: url, method: "PUT", body: requestBody, completion: completion)
    }

    /// Update user information (async version)
    /// - Parameter apnsToken: The APNS device token (optional)
    /// - Returns: UpdateUserResponse
    @available(iOS 13.0, *)
    public func updateUser(apnsToken: String? = nil) async throws -> UpdateUserResponse {
        try await withCheckedThrowingContinuation { continuation in
            updateUser(apnsToken: apnsToken) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// List notifications for the current user with pagination
    /// - Parameters:
    ///   - limit: Maximum number of notifications to return (default: 20, max: 100)
    ///   - cursor: Cursor for pagination (0 for first page, or the ID of the last notification from previous page)
    ///   - completion: Completion handler with paginated notifications response
    public func listNotifications(
        limit: Int = 20,
        cursor: Int = 0,
        completion: @escaping (Result<ListNotificationsResponse, Error>) -> Void
    ) {
        var components = URLComponents(string: baseURL + "/api/v1/notifications")!
        components.queryItems = [
            URLQueryItem(name: "channel", value: userConfig.channel),
            URLQueryItem(name: "channel_user_id", value: userConfig.channelUserID),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "cursor", value: String(cursor))
        ]
        
        guard let url = components.url else {
            completion(.failure(APIError.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let response = try JSONDecoder().decode(ListNotificationsResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            } else {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    completion(.failure(APIError.serverError(errorResponse.message)))
                } else {
                    completion(.failure(APIError.httpError(httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    /// List notifications for the current user with pagination (async version)
    /// - Parameters:
    ///   - limit: Maximum number of notifications to return (default: 20, max: 100)
    ///   - cursor: Cursor for pagination (0 for first page, or the ID of the last notification from previous page)
    /// - Returns: ListNotificationsResponse with paginated notifications
    @available(iOS 13.0, *)
    public func listNotifications(limit: Int = 20, cursor: Int = 0) async throws -> ListNotificationsResponse {
        try await withCheckedThrowingContinuation { continuation in
            listNotifications(limit: limit, cursor: cursor) { result in
                continuation.resume(with: result)
            }
        }
    }
    #endif
    
    // MARK: - Private Methods
    
    private func performRequest<T: Codable, U: Codable>(
        url: URL,
        method: String,
        body: T,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            // Success status codes: 200, 206 (partial content)
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 206 {
                do {
                    let decodedResponse = try JSONDecoder().decode(U.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(error))
                }
            } else {
                // Try to decode error response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    completion(.failure(APIError.serverError(errorResponse.message)))
                } else {
                    completion(.failure(APIError.httpError(httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    // MARK: - Error Types
    public enum APIError: LocalizedError {
        case noData
        case invalidResponse
        case httpError(Int)
        case serverError(String)
        
        public var errorDescription: String? {
            switch self {
            case .noData:
                return "No data received from server"
            case .invalidResponse:
                return "Invalid response from server"
            case .httpError(let code):
                return "HTTP error: \(code)"
            case .serverError(let message):
                return message
            }
        }
    }
}

// MARK: - Helper Types

/// Generic wrapper for decoding dynamic JSON values
public enum AnyCodable: Codable {
    case int(Int)
    case string(String)
    case double(Double)
    case bool(Bool)
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.typeMismatch(
                AnyCodable.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
    
    var intValue: Int? {
        if case .int(let value) = self { return value }
        return nil
    }
    
    var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }
    
    var doubleValue: Double? {
        if case .double(let value) = self { return value }
        return nil
    }
    
    var boolValue: Bool? {
        if case .bool(let value) = self { return value }
        return nil
    }
}

// MARK: - Usage Examples (commented out)
/*
// MARK: - Example Usage

// 1. Initialize the client
let config = AddressTrackerAPIClient.UserConfig(
    channel: "ios",
    channelUserID: "user123"
)
let client = AddressTrackerAPIClient(
    baseURL: "http://localhost:2020",
    userConfig: config
)

// 2. Get available networks
client.getAvailableNetworks { result in
    switch result {
    case .success(let networks):
        print("Available networks:")
        networks.forEach { print("- \($0.label) (\($0.network))") }
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

// 3. Add addresses (single network)
let ethereumAddresses = [
    AddressTrackerAPIClient.AddressInput(
        address: "0x1234567890123456789012345678901234567890",
        label: "My Wallet"
    ),
    AddressTrackerAPIClient.AddressInput(
        address: "0x0987654321098765432109876543210987654321",
        label: "Trading Wallet"
    )
]

client.addAddresses(["ETH_MAINNET": ethereumAddresses]) { result in
    switch result {
    case .success(let response):
        print("Added \(response.addresses.count) addresses")
        if let errors = response.webhookErrors {
            print("Webhook errors: \(errors)")
        }
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

// 4. Add addresses (multiple networks - bulk)
let bulkAddresses: [String: [AddressTrackerAPIClient.AddressInput]] = [
    "ETH_MAINNET": [
        AddressTrackerAPIClient.AddressInput(address: "0xaaa...", label: "ETH Wallet 1")
    ],
    "ARB_MAINNET": [
        AddressTrackerAPIClient.AddressInput(address: "0xbbb...", label: "ARB Wallet 1"),
        AddressTrackerAPIClient.AddressInput(address: "0xccc...", label: "ARB Wallet 2")
    ],
    "POLYGON_MAINNET": [
        AddressTrackerAPIClient.AddressInput(address: "0xddd...", label: "MATIC Wallet")
    ]
]

client.addAddresses(bulkAddresses) { result in
    // Handle result
}

// 5. List all addresses
client.listAddresses { result in
    switch result {
    case .success(let groupedAddresses):
        for (network, addresses) in groupedAddresses {
            print("\n\(network):")
            addresses.forEach { print("  - \($0.label): \($0.address)") }
        }
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

// 6. Remove addresses (bulk)
let addressesToRemove: [String: [String]] = [
    "ETH_MAINNET": [
        "0x1234567890123456789012345678901234567890"
    ],
    "ARB_MAINNET": [
        "0xbbb...",
        "0xccc..."
    ]
]

client.removeAddresses(addressesToRemove) { result in
    switch result {
    case .success(let response):
        print("Deleted: \(response.deletedAddresses)")
        print("Not found: \(response.notFound)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

// 7. Update a single address label
client.updateAddressLabel(
    addressId: 1,
    oldAddress: "0x1234567890123456789012345678901234567890",
    network: "ETH_MAINNET",
    newLabel: "Updated Wallet Name"
) { result in
    switch result {
    case .success:
        print("Label updated successfully")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

// 8. Update multiple address labels (bulk)
let labelUpdates: [String: [(address: String, newLabel: String)]] = [
    "ETH_MAINNET": [
        (address: "0xaaa...", newLabel: "New ETH Label")
    ],
    "ARB_MAINNET": [
        (address: "0xbbb...", newLabel: "New ARB Label 1"),
        (address: "0xccc...", newLabel: "New ARB Label 2")
    ]
]

client.updateAddressLabelsBulk(labelUpdates) { result in
    switch result {
    case .success:
        print("Labels updated successfully")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

// 9. Using async/await (iOS 15+)
@available(iOS 15.0, *)
func asyncExample() async {
    do {
        // Get networks
        let networks = try await client.getAvailableNetworks()
        print("Networks: \(networks)")
        
        // List addresses
        let addresses = try await client.listAddresses()
        print("Addresses: \(addresses)")
        
        // Add addresses
        let response = try await client.addAddresses(bulkAddresses)
        print("Added: \(response.addresses.count)")
        
        // Update label
        let success = try await client.updateAddressLabel(
            addressId: 1,
            oldAddress: "0xaaa...",
            network: "ETH_MAINNET",
            newLabel: "New Label"
        )
        print("Update success: \(success)")
        
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
*/

