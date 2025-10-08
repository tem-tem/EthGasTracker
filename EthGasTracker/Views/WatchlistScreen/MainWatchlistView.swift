//
//  MainWatchlistView.swift
//  EthGasTracker
//
//  Created by Tem on 10/1/25.
//

import SwiftUI
import Combine

// MARK: - ViewModel Wrapper for Reactivity
/// Wrapper to allow optional WatchlistVM to be properly observed by SwiftUI
class MainWatchlistViewModelWrapper: ObservableObject {
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

struct MainWatchlistView: View {
    @EnvironmentObject var storeVM: StoreVM
    @StateObject private var viewModelWrapper = MainWatchlistViewModelWrapper()
    @State private var showAddressList = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Use storeVM as source of truth for subscription status
            if !storeVM.subbed || storeVM.subscriptionIdentifier == nil {
                subscriptionRequiredView
            } else if let vm = viewModelWrapper.viewModel {
                // Have subscription and viewModel is initialized
                if vm.isLoadingNotifications && vm.notifications.isEmpty {
                    ProgressView("Loading activity...")
                } else if vm.notifications.isEmpty {
                    emptyStateView(vm: vm)
                } else {
                    notificationsList(vm: vm)
                }
                
                Divider()
                HStack {
                    Spacer()
                    Button {
                        showAddressList = true
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Manage Addresses")
                        }
                        .foregroundStyle(.primary)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.primary, lineWidth: 1)
                        )
                    }
                    Spacer()
                }
                .padding()
            } else {
                // Waiting for subscription check
                ProgressView("Checking subscription...")
            }
        }
        .sheet(isPresented: $showAddressList) {
            // Only show address list if subscription is active
            if storeVM.subbed, storeVM.subscriptionIdentifier != nil {
                AddressListView()
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
                        await viewModelWrapper.viewModel?.loadNotifications()
                        await viewModelWrapper.viewModel?.loadAddresses()
                        await viewModelWrapper.viewModel?.loadNetworks()
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
                    await viewModelWrapper.viewModel?.loadNotifications()
                    await viewModelWrapper.viewModel?.loadAddresses()
                    await viewModelWrapper.viewModel?.loadNetworks()
                }
            }
        }
        .onAppear {
            // Initialize viewModel if subscription is already available
            if storeVM.subbed, let subID = storeVM.subscriptionIdentifier, viewModelWrapper.viewModel == nil {
                viewModelWrapper.viewModel = WatchlistVM(subscriptionIdentifier: subID)
            }
        }
        .task {
            // Load data if viewModel exists
            if let vm = viewModelWrapper.viewModel {
                await vm.loadNotifications()
                await vm.loadAddresses()
                await vm.loadNetworks()
            }
        }
        .alert("Error", isPresented: .constant(viewModelWrapper.viewModel?.errorMessage != nil)) {
            Button("OK") {
                viewModelWrapper.viewModel?.errorMessage = nil
            }
        } message: {
            if let error = viewModelWrapper.viewModel?.errorMessage {
                Text(error)
            }
        }
    }
    
    private var subscriptionRequiredView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "arrow.left.arrow.right.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .opacity(0.5)
            Text("Track address activity across networks")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            Text("Upgrade to track up to 256 addresses and receive notifications for transactions.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Divider()
                .padding(.bottom)
            HStack {
                Spacer()
                SubscriptionView(source: "settings")
                Spacer()
            }
            .padding(.bottom)
        }
    }
    
    private func emptyStateView(vm: WatchlistVM) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.arrow.right.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Activity")
                .font(.title2)
                .fontWeight(.semibold)
            Text("You'll see activity here when addresses you track receive or send transactions")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    await vm.refreshNotifications()
                }
            } label: {
                Text("Refresh")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 50)
        }
    }
    
    private func notificationsList(vm: WatchlistVM) -> some View {
        List {
            ForEach(vm.notifications) { notification in
                Section {
                    NotificationRow(notification: notification, viewModel: vm)
                        .onAppear {
                            // Load more when reaching the last item
                            if notification.id == vm.notifications.last?.id {
                                Task {
                                    await vm.loadMoreNotifications()
                                }
                            }
                        }
                }
            }
            
            // Loading more indicator
            if vm.isLoadingNotifications {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            }
        }
        .refreshable {
            await vm.refreshNotifications()
        }
        .scrollContentBackground(.hidden) // Hides the default list background
        .background(Color.clear)
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notification: AddressTrackerAPIClient.Notification
    @ObservedObject var viewModel: WatchlistVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with network and timestamp
            
            // Event type not needed for now
            // Text(eventTypeFormatted(notification.eventType))
            //     .font(.subheadline)
            //     .fontWeight(.semibold)
            ZStack {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                HStack(spacing: 4) {
                    
                    if notification.preposition.lowercased() == "from" {
                        // Trigger sent to target: trigger -> target
                        AddressButton(
                            address: notification.triggerAddress,
                            network: networkLocal,
                            viewModel: viewModel,
                            isPrimary: true
                        )
                        Spacer()
                        
                        AddressButton(
                            address: notification.targetAddress,
                            network: networkLocal,
                            viewModel: viewModel,
                            isPrimary: false
                        )
                    } else {
                        // Trigger received from target: target -> trigger
                        AddressButton(
                            address: notification.targetAddress,
                            network: networkLocal,
                            viewModel: viewModel,
                            isPrimary: false
                        )
                        Spacer()
                        
                        AddressButton(
                            address: notification.triggerAddress,
                            network: networkLocal,
                            viewModel: viewModel,
                            isPrimary: true
                        )
                    }
                }
            }
            ZStack {
                if let value = notification.value, !value.isEmpty, let asset = notification.asset, !asset.isEmpty {
                    HStack {
                        Spacer()
                        // Value if present
                        Text("\(value)")
                            .foregroundColor(.secondary)
                        Text("\(asset)")
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text(networkLabel)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            Divider()

            HStack {
                // Transaction hash if present with link
                if let txHash = notification.txHash, let txLink = networkLocal?.txLink {
                    Button {
                        if let url = URL(string: txLink + txHash) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "link")
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                            Text(formatAddress(txHash))
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                        }
                    }
                } else if let txHash = notification.txHash {
                    HStack {
                        Image(systemName: "link")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formatAddress(txHash))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if let timestampView = HumanReadableTimestamp(iso8601String: notification.createdAt) {
                    timestampView
                } else {
                    Text(notification.createdAt)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical, 4)
    }
    
    // Look up NetworkLocal by matching the key
    private var networkLocal: NetworkLocal? {
        viewModel.localNetworks.first { $0.key == notification.network }
    }
    
    // Get network label or fallback to network key
    private var networkLabel: String {
        if let label = networkLocal?.network {
            return label
        }
        return notification.network.uppercased()
    }
    
    private func formatAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }
    
    private func networkColor(for network: String) -> Color {
        switch network.uppercased() {
        case let n where n.contains("ETH"):
            return .blue
        case let n where n.contains("POLYGON") || n.contains("MATIC"):
            return .purple
        case let n where n.contains("ARB"):
            return .cyan
        case let n where n.contains("BASE"):
            return .indigo
        case let n where n.contains("OPT"):
            return .red
        default:
            return .gray
        }
    }
    
    private func arrowIcon(for preposition: String) -> String {
        switch preposition.lowercased() {
        case "to":
            return "arrow.right"
        case "from":
            return "arrow.left"
        default:
            return "arrow.left.and.right"
        }
    }
    
    private func eventTypeFormatted(_ eventType: String) -> String {
        // Convert snake_case to Title Case
        return eventType
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
    
    private func timeAgo(from dateString: String) -> String {
        // Parse ISO8601 date string
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
        
        if let years = components.year, years > 0 {
            return "\(years)y ago"
        } else if let months = components.month, months > 0 {
            return "\(months)mo ago"
        } else if let days = components.day, days > 0 {
            return "\(days)d ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        } else if let seconds = components.second, seconds > 0 {
            return "\(seconds)s ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Address Button Component
struct AddressButton: View {
    let address: String
    let network: NetworkLocal?
    @ObservedObject var viewModel: WatchlistVM
    let isPrimary: Bool
    
    var body: some View {
        if let accountLink = network?.accountLink {
            // Clickable button with link
            Button {
                if let url = URL(string: accountLink + address) {
                    UIApplication.shared.open(url)
                }
            } label: {
                addressContent
            }
        } else {
            // Non-clickable text
            addressContent
        }
    }
    
    private var addressContent: some View {
        Text(displayText)
            .fontWeight(isPrimary ? .semibold : .regular)
            .foregroundColor(isPrimary ? .white : .primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isPrimary ? networkColor : Color.clear)
            .cornerRadius(12)
    }
    
    // Look up address label or use formatted address
    private var displayText: String {
        // Try to find the address in local addresses
        if let addressLocal = viewModel.localAddresses.first(where: { $0.address == address }) {
            return addressLocal.label ?? formatAddress(address)
        }
        return formatAddress(address)
    }
    
    private var networkColor: Color {
        guard let networkKey = network?.key else { return .gray }
        
        switch networkKey.uppercased() {
        case let n where n.contains("ETH"):
            return .blue
        case let n where n.contains("POLYGON") || n.contains("MATIC"):
            return .purple
        case let n where n.contains("ARB"):
            return .cyan
        case let n where n.contains("BASE"):
            return .indigo
        case let n where n.contains("OPT"):
            return .red
        default:
            return .gray
        }
    }
    
    private func formatAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }
}

#Preview {
    MainWatchlistView()
}
