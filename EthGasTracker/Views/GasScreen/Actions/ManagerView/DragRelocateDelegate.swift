//
//  DragRelocateDelegate.swift
//  EthGasTracker
//
//  Created by Tem on 2/12/24.
//

import SwiftUI
import UniformTypeIdentifiers

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
