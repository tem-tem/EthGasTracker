//
//  AddressListView.swift
//  EthGasTracker
//
//  Created by Tem on 10/1/25.
//

import SwiftUI
import Combine

// MARK: - ViewModel Wrapper
/// Wrapper to allow optional WatchlistVM to be properly observed by SwiftUI
class ViewModelWrapper: ObservableObject {
    @Published var viewModel: WatchlistVM? {
        didSet {
            // Cancel previous subscription
            cancellable?.cancel()
            
            // Subscribe to new viewModel's changes
            if let vm = viewModel {
                cancellable = vm.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
        }
    }
    
    private var cancellable: AnyCancellable?
}

// MARK: - Editing Address Model
struct EditingAddress: Identifiable {
    let id: Int
    let address: String
    let network: String
    let label: String
}

struct AddressListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storeVM: StoreVM
    @StateObject private var viewModelWrapper = ViewModelWrapper()
    @State private var showAddSheet = false
    @State private var editingAddress: EditingAddress?
    
    var body: some View {
        NavigationView {
            if let vm = viewModelWrapper.viewModel {
                contentView(vm: vm)
            } else {
                ProgressView("Initializing...")
                    .onAppear {
                        // Initialize viewModel if subscription is available
                        if storeVM.subbed, let subID = storeVM.subscriptionIdentifier {
                            viewModelWrapper.viewModel = WatchlistVM(subscriptionIdentifier: subID)
                        }
                    }
            }
        }
        .onChange(of: storeVM.subscriptionIdentifier) { newIdentifier in
            // Initialize or update viewModel when subscription identifier changes
            if let subID = newIdentifier, storeVM.subbed {
                if viewModelWrapper.viewModel == nil {
                    // Create new viewModel with subscription ID
                    viewModelWrapper.viewModel = WatchlistVM(subscriptionIdentifier: subID)
                    // Load data after initialization
                    Task {
                        await viewModelWrapper.viewModel?.loadNetworks()
                        await viewModelWrapper.viewModel?.loadAddresses()
                    }
                } else {
                    // Update existing viewModel
                    viewModelWrapper.viewModel?.updateSubscriptionIdentifier(subID)
                }
            } else {
                // No subscription, clear viewModel
                viewModelWrapper.viewModel = nil
            }
        }
        .onChange(of: storeVM.subbed) { isSubscribed in
            // React to subscription status changes
            if !isSubscribed {
                // Subscription lost, clear viewModel
                viewModelWrapper.viewModel = nil
            } else if let subID = storeVM.subscriptionIdentifier, viewModelWrapper.viewModel == nil {
                // Subscription gained, create viewModel
                viewModelWrapper.viewModel = WatchlistVM(subscriptionIdentifier: subID)
                Task {
                    await viewModelWrapper.viewModel?.loadNetworks()
                    await viewModelWrapper.viewModel?.loadAddresses()
                }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(vm: WatchlistVM) -> some View {
        ZStack {
            #if DEBUG
            VStack {
                if vm.isLoading && vm.localAddresses.isEmpty {
                    ProgressView("Loading...")
                } else if vm.localAddresses.isEmpty {
                    emptyStateView
                } else {
                    addressList(vm: vm)
                }
                debugInfo(vm: vm)
            }
            #else
                if vm.isLoading && vm.localAddresses.isEmpty {
                    ProgressView("Loading...")
                } else if vm.localAddresses.isEmpty {
                    emptyStateView
                } else {
                    addressList(vm: vm)
                }
            #endif
        }
        .navigationTitle("Addresses")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                    Text("Close")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                    Text("Add Address")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddAddressSheet(viewModel: vm, isPresented: $showAddSheet)
        }
        .sheet(item: $editingAddress) { item in
            EditLabelSheet(
                viewModel: vm,
                addressId: item.id,
                address: item.address,
                network: item.network,
                currentLabel: item.label,
                isPresented: Binding(
                    get: { editingAddress != nil },
                    set: { if !$0 { editingAddress = nil } }
                )
            )
        }
        .task {
            await vm.loadNetworks()
            await vm.loadAddresses()
        }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            if vm.needsNotificationPermission {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    vm.errorMessage = nil
                    vm.needsNotificationPermission = false
                }
                Button("Cancel", role: .cancel) {
                    vm.errorMessage = nil
                    vm.needsNotificationPermission = false
                }
            } else {
                Button("OK") {
                    vm.errorMessage = nil
                }
            }
        } message: {
            if let error = vm.errorMessage {
                Text(error)
            }
        }
    }
    
    private func debugInfo(vm: WatchlistVM) -> some View {
        VStack(spacing: 4) {
            Text("Debug Info")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Vendor ID: \(UIDevice.current.identifierForVendor?.uuidString.prefix(16) ?? "N/A")...")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if let deviceToken = DeviceTokenManager.shared.deviceToken {
                Text("✓ APNS Token: \(deviceToken.prefix(16))...")
                    .font(.caption2)
                    .foregroundColor(.green)
                Text("(Used for notifications)")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else {
                Text("⚠️ APNS Token: Not Available")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text("(Add address to get token)")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Addresses")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add blockchain addresses to track")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Add Address") {
                showAddSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func addressList(vm: WatchlistVM) -> some View {
        List {
            ForEach(groupedAddresses(from: vm)) { groupedAddress in
                WatchlistAddressRow(
                    groupedAddress: groupedAddress,
                    availableNetworks: vm.localNetworks,
                    onEdit: {
                        // Use the first address ID for editing
                        if let firstId = groupedAddress.addressIds.first,
                           let firstNetwork = groupedAddress.networks.first {
                            editingAddress = EditingAddress(
                                id: firstId,
                                address: groupedAddress.address,
                                network: firstNetwork,
                                label: groupedAddress.label
                            )
                        }
                    },
                    onDelete: {
                        Task {
                            // Delete from all networks
                            for network in groupedAddress.networks {
                                await vm.removeAddress(groupedAddress.address, network: network)
                            }
                        }
                    },
                    onToggleNotifications: { enabled in
                        Task {
                            // Toggle notifications for all networks
                            for network in groupedAddress.networks {
                                await vm.toggleNotifications(
                                    address: groupedAddress.address,
                                    network: network,
                                    enabled: enabled
                                )
                            }
                        }
                    },
                    viewModel: vm
                )
            }
        }
        .refreshable {
            await vm.loadAddresses()
        }
    }
    
    // Group addresses by address string
    private func groupedAddresses(from vm: WatchlistVM) -> [GroupedAddress] {
        var addressGroups: [String: [AddressLocal]] = [:]
        
        // Group all addresses by their address string
        for addressLocal in vm.localAddresses {
            guard let address = addressLocal.address else { continue }
            if addressGroups[address] == nil {
                addressGroups[address] = []
            }
            addressGroups[address]?.append(addressLocal)
        }
        
        // Convert to GroupedAddress array and sort by label
        return addressGroups.map { address, addresses in
            GroupedAddress(address: address, localAddresses: addresses)
        }.sorted { $0.label < $1.label }
    }
}


// MARK: - Add Address Sheet
struct AddAddressSheet: View {
    @ObservedObject var viewModel: WatchlistVM
    @Binding var isPresented: Bool
    
    @State private var selectedNetworks: Set<String> = []
    @State private var addressText = "0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97"
    @State private var labelText = "TitanBuilder"
    
    // Check which networks already have this address
    private func isNetworkAlreadyTracked(_ networkKey: String) -> Bool {
        return viewModel.localAddresses.contains { address in
            address.address?.lowercased() == addressText.lowercased() &&
            address.network?.key == networkKey
        }
    }
    
    private var trackedNetworks: Set<String> {
        Set(viewModel.localAddresses
            .filter { $0.address?.lowercased() == addressText.lowercased() }
            .compactMap { $0.network?.key })
    }
    
    private var availableSlots: Int {
        max(0, ADDRESS_LIMIT - viewModel.localAddresses.count)
    }
    
    private var isLimitReached: Bool {
        viewModel.localAddresses.count >= ADDRESS_LIMIT
    }
    
    private var wouldExceedLimit: Bool {
        viewModel.localAddresses.count + selectedNetworks.count > ADDRESS_LIMIT
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Address limit warning
                if availableSlots <= 10 {
                    Section {
                        HStack {
                            Image(systemName: isLimitReached ? "exclamationmark.triangle.fill" : "info.circle.fill")
                                .foregroundColor(isLimitReached ? .red : .orange)
                            Text(isLimitReached ? "Address limit reached (\(ADDRESS_LIMIT)/\(ADDRESS_LIMIT))" : "Only \(availableSlots) slots remaining")
                                .font(.caption)
                        }
                    }
                }
                
                Section(header: Text("Networks")) {
                    ForEach(viewModel.localNetworks) { network in
                        let networkKey = network.key ?? ""
                        let isTracked = isNetworkAlreadyTracked(networkKey)
                        
                        HStack {
                            MultipleSelectionRow(
                                title: network.network ?? "",
                                isSelected: selectedNetworks.contains(networkKey)
                            ) {
                                if !isTracked && !isLimitReached {
                                    if selectedNetworks.contains(networkKey) {
                                        selectedNetworks.remove(networkKey)
                                    } else {
                                        selectedNetworks.insert(networkKey)
                                    }
                                }
                            }
                            
                            if isTracked {
                                Text("Already tracked")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .opacity(isTracked ? 0.5 : 1.0)
                        .disabled(isTracked)
                    }
                }
                
                Section(header: Text("Address Details")) {
                    TextField("Address", text: $addressText)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .onChange(of: addressText) { _ in
                            // Clear selections for networks that already track this address
                            selectedNetworks = selectedNetworks.filter { networkKey in
                                !isNetworkAlreadyTracked(networkKey)
                            }
                        }
                    
                    TextField("Label (Optional)", text: $labelText)
                }
                
                Section {
                    Button("Add Address") {
                        Task {
                            let label = labelText.isEmpty ? addressText : labelText
                            await viewModel.addAddressToNetworks(addressText, label: label, networks: selectedNetworks)
                            isPresented = false
                        }
                    }
                    .disabled(selectedNetworks.isEmpty || addressText.isEmpty || wouldExceedLimit)
                    
                    if wouldExceedLimit && !selectedNetworks.isEmpty {
                        Text("Adding \(selectedNetworks.count) address(es) would exceed the limit of \(ADDRESS_LIMIT)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Edit Label Sheet
struct EditLabelSheet: View {
    @ObservedObject var viewModel: WatchlistVM
    let addressId: Int
    let address: String
    let network: String
    let currentLabel: String
    @Binding var isPresented: Bool
    
    @State private var newLabel = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Address")) {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Label")) {
                    TextField("Label", text: $newLabel)
                }
                
                Section {
                    Button("Update Label") {
                        Task {
                            await viewModel.updateLabel(
                                addressId: addressId,
                                address: address,
                                network: network,
                                newLabel: newLabel
                            )
                            isPresented = false
                        }
                    }
                    .disabled(newLabel.isEmpty || newLabel == currentLabel)
                }
            }
            .navigationTitle("Edit Label")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                newLabel = currentLabel
            }
        }
    }
}

// MARK: - Multiple Selection Row
struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

#Preview {
    AddressListView()
}

