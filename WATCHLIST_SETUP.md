# Address Watchlist Setup

## Files Created/Modified

### 1. **WatchlistVM.swift** (NEW)
Location: `EthGasTracker/EthGasTracker/ViewModels/WatchlistVM.swift`

ViewModel that manages the AddressTrackerAPIClient and handles:
- Loading addresses from the API
- Loading available networks
- Adding new addresses
- Removing addresses
- Updating address labels

**Configuration:**
- **Channel**: Set to `"ios"`
- **User ID**: Uses `UIDevice.current.identifierForVendor?.uuidString` (unique per device, persists until app is uninstalled)
- **Base URL**: Currently set to `http://localhost:2020` (change for production)

### 2. **MainWatchlistView.swift** (UPDATED)
Location: `EthGasTracker/EthGasTracker/Views/WatchlistScreen/MainWatchlistView.swift`

Complete watchlist interface with:
- List of addresses grouped by network
- Empty state when no addresses are tracked
- Pull to refresh
- Add address sheet with network picker
- Edit label functionality
- Delete addresses via swipe actions
- Context menu for copy/edit/delete

## Setup Instructions

### 1. Add WatchlistVM.swift to Xcode Project
The `WatchlistVM.swift` file needs to be added to your Xcode project:

1. Open the Xcode project
2. Right-click on the `ViewModels` folder
3. Select "Add Files to EthGasTracker..."
4. Navigate to and select `WatchlistVM.swift`
5. Ensure "Copy items if needed" is unchecked (file is already in place)
6. Ensure your target is selected
7. Click "Add"

### 2. Configure Base URL

Update the base URL in `WatchlistVM.swift` for your environment:

```swift
init(baseURL: String = "YOUR_PRODUCTION_URL") {
    // ...
}
```

Or pass it dynamically when creating the view model.

### 3. Backend Requirements

Ensure your Address Tracker backend is running and accessible:
- REST API should be available at the configured base URL
- Required endpoints:
  - `POST /api/v1/track` - Add addresses
  - `POST /api/v1/untrack` - Remove addresses
  - `POST /api/v1/list` - List addresses
  - `GET /api/v1/webhooks` - Get available networks

## Features

### User Interface
- ✅ **List View**: Displays all tracked addresses grouped by blockchain network
- ✅ **Add Addresses**: Sheet-based form to add new addresses with network selection
- ✅ **Edit Labels**: Update the label/name for any tracked address
- ✅ **Delete Addresses**: Swipe-to-delete or context menu deletion
- ✅ **Copy Address**: Long-press context menu to copy address to clipboard
- ✅ **Pull to Refresh**: Reload addresses from server
- ✅ **Status Badges**: Visual indicators for address status (Active/Created)
- ✅ **Empty State**: Helpful UI when no addresses are tracked
- ✅ **Error Handling**: Alert dialogs for API errors

### User Identification
- Uses device vendor identifier (`identifierForVendor`)
- Unique per device per vendor (Apple Developer account)
- Persists across app launches
- Resets when app is uninstalled
- Can be used by backend to send push notifications to this specific device

## Usage Example

The view is already set up and ready to use. Just navigate to `MainWatchlistView()` in your app:

```swift
NavigationView {
    MainWatchlistView()
}
```

Or if it's in a TabView:
```swift
TabView {
    MainWatchlistView()
        .tabItem {
            Label("Watchlist", systemImage: "list.bullet")
        }
}
```

## Network Support

The app dynamically loads supported networks from your backend. Common networks include:
- Ethereum (ETH_MAINNET, ETH_SEPOLIA, etc.)
- Arbitrum (ARB_MAINNET, ARB_SEPOLIA, etc.)
- Polygon (POLYGON_MAINNET, POLYGON_MUMBAI)
- Optimism (OPT_MAINNET, OPT_GOERLI)
- Base (BASE_MAINNET, BASE_SEPOLIA)
- And more...

## Notes

- The device identifier is automatically retrieved and used for API calls
- All API calls use async/await for better performance
- The UI automatically updates after any operation
- Addresses are validated by the backend
- Labels default to the address itself if not provided

