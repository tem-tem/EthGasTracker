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
    @EnvironmentObject var liveDataVM: LiveDataVM
    @State private var dragging: CustomActionEntity? = nil
    @State private var customActions: [CustomActionEntity] = []
    @State private var showingForm = false
    @State private var isDeleting = false
    @AppStorage("subbed") var subbed: Bool = false
    @State private var showingPurchaseView = false
    
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
                                    ActionSMView(name: action.name ?? "", groupName: action.group ?? "", value: CustomActionEntity.calcCost(for: Double(action.limit), ethPrice: liveDataVM.ethPrice, gas: liveDataVM.gasLevel.currentGas), primaryColor: .primary, secondaryColor: .secondary)
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
            
            if isDeleting {
                Button {
                    isDeleting.toggle()
                } label: {
                    BorderedText(value: "Done")
                }
                .padding()
            } else {
                HStack {
                    Button {
                        if customActions.filter({ !$0.isServerAction }).count > 0 {
                            isDeleting = true
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }.opacity(customActions.filter({ !$0.isServerAction }).count == 0 ? 0 : 1)
                    Spacer()
                    Button {
                        if subbed {
                            showingForm.toggle()
                        } else {
                            showingPurchaseView.toggle()
                        }
                    } label: {
                        BorderedText(value: "Add Action")
                    }
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    .opacity(0)
                }
                .padding()
            }
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
        .sheet(isPresented: $showingForm) {
            ActionFormView(isPresented: $showingForm)
                .presentationDetents([.medium])
                .onDisappear {
                    customActionDM.fetchCustomActions()
                    self.customActions = customActionDM.actions
                }
        }
        .sheet(isPresented: $showingPurchaseView) {
                PurchaseView()
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

struct DragRelocateDelegate: DropDelegate {
    let item: CustomActionEntity
    @Binding var listData: [CustomActionEntity]
    @Binding var current: CustomActionEntity?

    func dropEntered(info: DropInfo) {
        // When a drag enters a new item, we can decide to reorder immediately
        if item != current,
           let fromIndex = listData.firstIndex(where: { $0.id == current?.id }),
           let toIndex = listData.firstIndex(where: { $0.id == item.id }) {
            if listData[toIndex].id != current?.id {
                listData.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        // This method is called when the user drops the item. We can use this to finalize the reordering or handle deletion.
        // For now, we'll simply reset the `current` dragging item to nil.
        self.current = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        // This can be used to provide visual feedback about what the drop will do, e.g., copy, move, or forbidden.
        // For reordering, `.move` is typically appropriate.
        return DropProposal(operation: .move)
    }
}



#Preview {
    PreviewWrapper {
        ActionsManagerView()
            .background(Color("BG.L0"))
    }
}
