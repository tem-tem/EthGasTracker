//
//  ControlBar.swift
//  EthGasTracker
//
//  Created by Tem on 2/12/24.
//

import SwiftUI

struct ControlBar: View {
    @EnvironmentObject var customActionDM: CustomActionDataManager
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    @Binding var customActions: [CustomActionEntity]
    @Binding var showingForm: Bool
    @Binding var showingPurchaseView: Bool
    @Binding var isDeleting: Bool
    @AppStorage("subbed") var subbed: Bool = false
    @Binding var showingWheel: Bool
    
    var body: some View {
        VStack {
            HStack {
                if isDeleting {
                    Button {
                        isDeleting.toggle()
                    } label: {
                        BorderedText(value: "Done")
                    }
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
                        if showingWheel {
                            if let gas = activeSelectionVM.gas {
                                Text("\(Int(gas))")
                                    .foregroundStyle(.purple)
                                    .font(.system(size: 32, weight: .bold, design: .monospaced
                                                 ))
                            }
                        } else {
                            Button {
                                if subbed {
                                    showingForm.toggle()
                                } else {
                                    showingPurchaseView.toggle()
                                }
                            } label: {
                                BorderedText(value: "Add Action")
                            }
                        }
                        Spacer()
                        Button {
                            if subbed {
                                withAnimation() {
                                    showingWheel.toggle()
                                }
                            } else {
                                showingPurchaseView.toggle()
                            }
                        } label: {
                            Image(systemName: "plus.forwardslash.minus")
                                .foregroundColor(.purple)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            
        }
        .frame(height: 40)
        .padding()
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
        .onChange(of: showingWheel) { _ in
            activeSelectionVM.drop()
        }
    }
}

#Preview {
    PreviewWrapper {
        ControlBar(
            customActions: .constant([]),
            showingForm: .constant(false),
            showingPurchaseView: .constant(false),
            isDeleting: .constant(false),
            showingWheel: .constant(false)
        )
        .background(Color("BG.L0"))
    }
}
