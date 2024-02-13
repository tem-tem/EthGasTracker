//
//  ActionFormView.swift
//  EthGasTracker
//
//  Created by Tem on 2/10/24.
//
import SwiftUI

struct ActionFormView: View {
    @EnvironmentObject var dataManager: CustomActionDataManager
    var actionToEdit: CustomActionEntity?
    @State private var name: String = ""
    @State private var group: String = ""
    @State private var limit: Int64 = 0
    @State private var showError: Bool = false
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Action Details")) {
                    TextField("Name", text: $name)
                    TextField("Group", text: $group)
                    // no more than 6 digits
                    TextField("Limit", value: $limit, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .onChange(of: limit) { newValue in
                            if String(newValue).count > 6 {
                                limit = Int64(String(newValue).prefix(6)) ?? 0
                            }
                        }
                }
                
                Section {
                    Button(actionToEdit == nil ? "Add Action" : "Update Action") {
                        if name.isEmpty || group.isEmpty {
                            showError = true
                        } else {
                            addOrUpdateAction()
                        }
                    }
                }
            }
            .navigationTitle(actionToEdit == nil ? "Add New Action" : "Edit Action")
//            .alert(isPresented: $showError) {
//                Alert(title: Text("Error"), message: Text("Name and Group cannot be empty."), dismissButton: .default(Text("OK")))
//            }
        }
        .onAppear {
            if let actionToEdit = actionToEdit {
                name = actionToEdit.name ?? ""
                group = actionToEdit.group ?? ""
                limit = actionToEdit.limit
            }
        }
    }
    
    private func addOrUpdateAction() {
        if let actionToEdit = actionToEdit {
            // Update existing action
            let key = "\(name)_\(group)"
            dataManager.updateCustomAction(actionToEdit, key: key, group: group, name: name, limit: limit, isServerAction: false)
        } else {
            // Add new action
            let key = "\(name)_\(group)"
            dataManager.addCustomAction(key: key, group: group, name: name, limit: limit, isServerAction: false)
        }
        isPresented = false
    }
}


#Preview {
    ActionFormView(isPresented: .constant(true))
}
