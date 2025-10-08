//
//  WatchlistAddressRow.swift
//  EthGasTracker
//
//  Created by Tem on 10/3/25.
//

import SwiftUI

struct WatchlistAddressRow: View {
    let groupedAddress: GroupedAddress
    let availableNetworks: [NetworkLocal]
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleNotifications: (Bool) -> Void
    @ObservedObject var viewModel: WatchlistVM
    
    @State private var showNetworksSheet = false
    @State private var isTogglingTracking = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // First row: Address info with notification toggle
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(groupedAddress.label)
                        .font(.headline)
                    Text(groupedAddress.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                Spacer()
                // Tracking toggle button
                if isTogglingTracking {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Button {
                        Task {
                            await toggleTracking()
                        }
                    } label: {
                        Image(systemName: groupedAddress.isLocalOnly ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(groupedAddress.isLocalOnly ? .gray : .blue)
                            .font(.system(size: 20))
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(groupedAddress.networks, id: \.self) { network in
                            NetworkBadge(network: network, availableNetworks: availableNetworks)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                Button {
                    showNetworksSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                        Text("Networks")
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundColor(.accentColor)
                    .cornerRadius(6)
                }
                Menu {
                    Button {
                        UIPasteboard.general.string = groupedAddress.address
                    } label: {
                        Label("Copy Address", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        onEdit()
                    } label: {
                        Label("Edit Label", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(4)
                        .contentShape(Rectangle())
                }
                .labelsHidden()
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = groupedAddress.address
            } label: {
                Label("Copy Address", systemImage: "doc.on.doc")
            }
            
            Button {
                onEdit()
            } label: {
                Label("Edit Label", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showNetworksSheet) {
            NetworksManagementSheet(
                groupedAddress: groupedAddress,
                availableNetworks: availableNetworks,
                isPresented: $showNetworksSheet,
                viewModel: viewModel
            )
            .presentationDetents([.medium, .large])
        }
    }
    
    private var statusBadge: some View {
        Text(groupedAddress.status.capitalized)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
    
    private var statusColor: Color {
        switch groupedAddress.status.lowercased() {
        case "active":
            return .green
        case "created":
            return .blue
        default:
            return .gray
        }
    }
    
    private func toggleTracking() async {
        isTogglingTracking = true
        await viewModel.toggleTracking(address: groupedAddress.address, enabled: groupedAddress.isLocalOnly)
        isTogglingTracking = false
    }
}

// MARK: - Network Badge
struct NetworkBadge: View {
    let network: String
    let availableNetworks: [NetworkLocal]
    
    var body: some View {
        Text(networkInitial)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(6)
    }
    
    private var networkInitial: String {
        // Get the label for the network, or use the network key
        let label = availableNetworks.first(where: { $0.key == network })?.label ?? network
        
        // Return first 3 characters or first letter of each word
        if label.contains(" ") {
            return label.split(separator: " ")
                .compactMap { $0.first }
                .map { String($0).uppercased() }
                .joined()
                .prefix(3)
                .uppercased()
        } else {
            return label.prefix(3).uppercased()
        }
    }
}

// MARK: - Networks Management Sheet
struct NetworksManagementSheet: View {
    let groupedAddress: GroupedAddress
    let availableNetworks: [NetworkLocal]
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: WatchlistVM
    
    @State private var selectedNetworks: Set<String>
    @State private var isProcessing: Set<String> = []
    @State private var isProcessingNotifications: Set<String> = []
    @State private var errorMessage: String?
    
    init(groupedAddress: GroupedAddress, availableNetworks: [NetworkLocal], isPresented: Binding<Bool>, viewModel: WatchlistVM) {
        self.groupedAddress = groupedAddress
        self.availableNetworks = availableNetworks
        self._isPresented = isPresented
        self.viewModel = viewModel
        self._selectedNetworks = State(initialValue: Set(groupedAddress.networks))
    }
    
    var body: some View {
        NavigationView {
            List {
                if let errorMessage = errorMessage {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                ForEach(availableNetworks) { network in
                    if let key = network.key {
                        Section {
                            // Network toggle
                            HStack {
                                if isProcessing.contains(key) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .frame(width: 16, height: 16)
                                } else {
                                        
                                    Image(systemName: "eye.fill")
                                        .foregroundColor(.cyan)
                                        .frame(width: 16, height: 16)
                                }
                                Text(network.label ?? network.network ?? "")
                                Spacer()
                                    Toggle("", isOn: Binding(
                                        get: { selectedNetworks.contains(key) },
                                        set: { _ in
                                            Task {
                                                await toggleNetwork(key)
                                            }
                                        }
                                    ))
                                    .labelsHidden()
                                    .disabled(isProcessing.contains(key))
                            }
                            
                            // Push notification toggle (only shown if network is enabled)
                            if selectedNetworks.contains(key) {
                                HStack {
                                    if isProcessingNotifications.contains(key) {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .frame(width: 16, height: 16)
                                    } else {
                                        Image(systemName: "bell.fill")
                                            .foregroundColor(.cyan)
                                            .frame(width: 16, height: 16)
                                    }
                                    Text("Notifications")
                                    Spacer()
                                    Toggle("", isOn: Binding(
                                        get: { 
                                            groupedAddress.notificationStateByNetwork[key] ?? false
                                        },
                                        set: { newValue in
                                            Task {
                                                await toggleNotifications(key, enabled: newValue)
                                            }
                                        }
                                    ))
                                    .labelsHidden()
                                    .disabled(isProcessingNotifications.contains(key))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Networks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func toggleNetwork(_ networkKey: String) async {
        // Validate: must have at least one network enabled
        if selectedNetworks.contains(networkKey) && selectedNetworks.count == 1 {
            errorMessage = "At least one network must be enabled"
            return
        }
        
        errorMessage = nil
        isProcessing.insert(networkKey)
        
        if selectedNetworks.contains(networkKey) {
            // Remove network
            await viewModel.removeAddress(groupedAddress.address, network: networkKey)
            selectedNetworks.remove(networkKey)
        } else {
            // Add network
            await viewModel.addAddress(groupedAddress.address, label: groupedAddress.label, network: networkKey)
            selectedNetworks.insert(networkKey)
        }
        
        isProcessing.remove(networkKey)
    }
    
    private func toggleNotifications(_ networkKey: String, enabled: Bool) async {
        isProcessingNotifications.insert(networkKey)
        
        await viewModel.toggleNotifications(
            address: groupedAddress.address,
            network: networkKey,
            enabled: enabled
        )
        
        isProcessingNotifications.remove(networkKey)
    }
}

// MARK: - Network Toggle Row
struct NetworkToggleRow: View {
    let network: AddressTrackerAPIClient.Network
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(network.label ?? network.network)
                    .font(.body)
                Text(network.key)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
    }
}

// MARK: - Grouped Address Model
struct GroupedAddress: Identifiable {
    let id: String // Use address as ID
    let address: String
    let label: String
    let networks: [String]
    let status: String
    let isNotificationsEnabled: Bool
    let isLocalOnly: Bool // True if address is only stored locally (not tracked on server)
    let addressIds: [Int] // IDs of all address entries across networks
    let notificationStateByNetwork: [String: Bool] // Per-network notification state
    
    init(address: String, addresses: [AddressTrackerAPIClient.Address]) {
        self.id = address
        self.address = address
        // Use label from first address (they should all be the same)
        self.label = addresses.first?.label ?? address
        self.networks = addresses.map { $0.network }
        // Use status from first address
        self.status = addresses.first?.status ?? "unknown"
        // Check if all addresses have notifications enabled
        self.isNotificationsEnabled = addresses.allSatisfy { $0.isNotificationsEnabled }
        self.isLocalOnly = false // API addresses are always tracked on server
        self.addressIds = addresses.map { $0.id }
        // Map network to notification state
        var notificationMap: [String: Bool] = [:]
        for addr in addresses {
            notificationMap[addr.network] = addr.isNotificationsEnabled
        }
        self.notificationStateByNetwork = notificationMap
    }
    
    init(address: String, localAddresses: [AddressLocal]) {
        self.id = address
        self.address = address
        // Use label from first address (they should all be the same)
        self.label = localAddresses.first?.label ?? address
        self.networks = localAddresses.compactMap { $0.network?.key }
        // Use status from first address
        self.status = localAddresses.first?.status ?? "unknown"
        // Check if all addresses have notifications enabled
        self.isNotificationsEnabled = localAddresses.allSatisfy { $0.isNotificationEnabled }
        // Check if ALL addresses are local-only (if any is tracked on server, show as tracked)
        self.isLocalOnly = localAddresses.allSatisfy { $0.isLocalOnly }
        self.addressIds = localAddresses.compactMap { Int($0.id) }
        // Map network to notification state
        var notificationMap: [String: Bool] = [:]
        for addr in localAddresses {
            if let networkKey = addr.network?.key {
                notificationMap[networkKey] = addr.isNotificationEnabled
            }
        }
        self.notificationStateByNetwork = notificationMap
    }
}

