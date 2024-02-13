//
//  ActionsManagerView.swift
//  EthGasTracker
//
//  Created by Tem on 2/9/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ActionsManagerView: View {
    let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
    @EnvironmentObject var customActionDM: CustomActionDataManager
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    @EnvironmentObject var liveDataVM: LiveDataVM
    @State private var dragging: CustomActionEntity? = nil
    @State private var customActions: [CustomActionEntity] = []
    @State private var showingForm = false
    @State private var isDeleting = false
    @State private var showingPurchaseView = false
    @AppStorage("subbed") var subbed: Bool = false
    @Binding var showingWheel: Bool
    
    var cols: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: cols, spacing: 10) {
                    ForEach(customActions) { action in
                        ZStack {
                            if isDeleting && !action.isServerAction {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                    .onTapGesture {
                                        customActionDM.deleteCustomAction(action)
                                        customActions = customActionDM.actions
                                        if customActions.filter({ !$0.isServerAction }).count == 0 {
                                            isDeleting = false
                                        }
                                        hapticHeavy.impactOccurred()
                                    }
                            }
                            VStackWithRoundedBorder(padding: 8) {
                                HStack {
                                    ActionSMView(
                                        name: action.name ?? "",
                                        groupName: action.group ?? "",
                                        value: CustomActionEntity.calcCost(
                                            for: Double(action.limit),
                                            ethPrice: liveDataVM.ethPrice,
                                            gas: activeSelectionVM.gas ?? liveDataVM.gasLevel.currentGas),
                                        primaryColor: showingWheel ? .purple : .primary,
                                        secondaryColor: .secondary
                                    )
                                    Spacer()
                                }
                                Spacer()
                                Divider()
                                Text("\(action.limit)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .background(action.pinned ? Color("BG.L1") : Color("BG.L0"))
                        .cornerRadius(10)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onDrag {
                            self.dragging = action
                            let provider = NSItemProvider(object: String(describing: action.id) as NSString)
                            
                            // Create a UIDragItem with the NSItemProvider
                            let dragItem = UIDragItem(itemProvider: provider)
                            
                            // Set a preview provider for the UIDragItem
                            dragItem.previewProvider = {
                                // Generate the drag preview here
                                let snapshotView = self.createSnapshotView(for: action) // Ensure this is a UIView
                                let renderer = UIGraphicsImageRenderer(size: snapshotView.bounds.size)
                                let image = renderer.image { _ in
                                    snapshotView.drawHierarchy(in: snapshotView.bounds, afterScreenUpdates: true)
                                }
                                
                                // Create a UIDragPreview using the rendered image
                                let preview = UIDragPreview(view: UIImageView(image: image))
                                return preview
                            }
                            
                            // Since .onDrag expects a single NSItemProvider, return the original provider
                            // The dragItem with its previewProvider is not directly used here due to SwiftUI limitations
                            return provider
                        }


                        .onDrop(of: [.text], delegate: DragRelocateDelegate(item: action, listData: $customActions, current: $dragging))
                    
                    }
                    
                }
                .padding(10)
            }
            Divider()
            ControlBar(
                customActions: $customActions,
                showingForm: $showingForm,
                showingPurchaseView: $showingPurchaseView,
                isDeleting: $isDeleting,
                showingWheel: $showingWheel
            )
        }
        .onAppear {
            customActionDM.fetchCustomActions()
            self.customActions = customActionDM.actions
        }
        .onChange(of: customActions) { newlyOrderedActions in
            let isOrderModified = newlyOrderedActions != customActionDM.actions
            if isOrderModified {
                if subbed {
                    customActionDM.reorder(actions: newlyOrderedActions)
                } else {
                    dragging = nil
                    showingPurchaseView.toggle()
                    customActions = customActionDM.actions
                }
            }
        }
    }
    
    func createSnapshotView(for action: CustomActionEntity) -> UIView {
        // Create a SwiftUI view that represents your draggable item
        let swiftUIView = VStackWithRoundedBorder(padding: 8) {
            
                HStack {
                    ActionSMView(name: action.name ?? "", groupName: action.group ?? "", value: CustomActionEntity.calcCost(for: Double(action.limit), ethPrice: liveDataVM.ethPrice, gas: liveDataVM.gasLevel.currentGas), primaryColor: .primary, secondaryColor: .secondary)
                    Spacer()
                }
                Spacer()
                Divider()
                Text("\(action.limit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .cornerRadius(10)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        
        // Convert the SwiftUI view to a UIKit UIView
        let hostingController = UIHostingController(rootView: swiftUIView)
        return hostingController.view
    }

    
    private func deleteAction(at offsets: IndexSet) {
        for index in offsets {
            let action = customActionDM.actions[index]
            customActionDM.deleteCustomAction(action)
        }
        customActionDM.fetchCustomActions() // Refresh the list after deletion
    }
    
    private func moveAction(from source: IndexSet, to destination: Int) {
        print("from \(source) to \(destination)")
        customActionDM.moveCustomAction(from: source, to: destination)
    }
}


#Preview {
    PreviewWrapper {
        ActionsManagerView(showingWheel: .constant(false))
            .background(Color("BG.L0"))
    }
}
