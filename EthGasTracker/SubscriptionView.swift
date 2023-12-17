//
//  SubscriptionView.swift
//  ExpenseLog
//
//  Created by Tem on 9/23/23.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @AppStorage(SettingsKeys().colorScheme) var settingsColorScheme: ColorScheme = .none
    @Environment(\.colorScheme) var colorScheme
    var currentColorScheme: ColorScheme {
        if settingsColorScheme == .none {
            return colorScheme == .light ? .light : .dark
        } else {
            return settingsColorScheme
        }
    }
    @EnvironmentObject var storeVM: StoreVM
    @State var isPresented = false
    
    var body: some View {
        
//            PurchaseView()
        VStack(alignment: .center) {
            if storeVM.purchasedSubscriptions.isEmpty {
                Button {
                    print("tapped on buy")
                    isPresented = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Get Gas Alert Plus")
                            .foregroundColor(.white)
                            .bold()
                        Spacer()
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .background(Color.accentColor.gradient)
                .clipShape(Capsule())
                .sheet(isPresented: $isPresented) {
                    PurchaseView()
                }
                .padding()
                Text("This is the best way to support the app, and keep it running.")
                    .font(.caption)
                    .multilineTextAlignment(.center)

            } else {
//                Text("Gas Plus is active")
                EmptyView()
            }
        }
    }
}

struct GoodStuff: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: "infinity")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemPurple))
                    .background(Color(.systemPurple).opacity(0.1))
                    .cornerRadius(7)
                
                VStack(alignment: .leading) {
                    Text("Unlimited Alerts")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("Create as many as you want.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "powersleep")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemIndigo))
                    .background(Color(.systemIndigo).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("Custom Off Hours")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    HStack {
                        Text("No alerts during chosen hours.").font(.caption)
                        Spacer()
                    }
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "clock.badge.checkmark")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemGreen))
                    .background(Color(.systemGreen).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("Confirmations")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("Get alerts only if gas satisfies the condition for a certain time.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "bolt.badge.clock")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemRed))
                    .background(Color(.systemRed).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("Limited Lifespan")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("Auto-Disables alert after a certain number of notifications.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "arrow.left.arrow.right.circle")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.purple))
                    .background(Color(.purple).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("160+ Currencies")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("See Ethereum price and actions in 160+ different currencies.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "chart.xyaxis.line")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemTeal))
                    .background(Color(.systemTeal).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("Historical Data")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("Past hour, day, week, month.").font(.caption)
                }
            }
        }
    }
}

struct NextGoodStuff: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: "star.bubble")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemGreen))
                    .background(Color(.systemGreen).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("Text Alerts (SMS)")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("Why not.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "plus.forwardslash.minus")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemBlue))
                    .background(Color(.systemBlue).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("Action Features")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("Create custom actions, and change what's displayed on the homescreen.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "paintpalette")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemPink))
                    .background(Color(.systemPink).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("Customizations. Icons, Colors, Levels")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("Still waiting for our artist to draw an icon... at least one. Come on dude, it's been a year already.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "macbook.and.iphone")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemIndigo))
                    .background(Color(.systemIndigo).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("iPad, Mac, Watch Support")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("God help us go through testing for all of the screen sizes.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "slowmo")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemMint))
                    .background(Color(.systemMint).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("More Precise Averages")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("Down to the minutes, not just hours.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "chart.bar.xaxis")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemGreen))
                    .background(Color(.systemGreen).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("Reports")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("Brings most important stuff to the surface.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "rectangle.3.group.fill")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemOrange))
                    .background(Color(.systemOrange).opacity(0.1))
                    .cornerRadius(7)
                VStack(alignment: .leading) {
                    Text("Widgets")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("More widgets, but with extra stuff.").font(.caption)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "checkerboard.rectangle")
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(.systemPurple))
                    .background(Color(.systemPurple).opacity(0.1))
                    .cornerRadius(7)
                
                VStack(alignment: .leading) {
                    Text("Heatmaps")
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("It's coming back. Yep.").font(.caption)
                }
            }
        }
    }
}

struct BuyButtons: View {
    @EnvironmentObject var storeVM: StoreVM
    @State var isPurchased = false
    
    var sortedSubscriptionsByPrice: [Product] {
        storeVM.subscriptions.sorted { $0.price < $1.price }
    }
    
    var body: some View {
        ForEach(sortedSubscriptionsByPrice) { product in
            Button {
                Task {
                    await buy(product)
                }
            } label: {
                HStackWithRoundedBorder() {
                    VStack(alignment: .leading) {
                        Text(product.displayName).bold()
                        Text(product.description).font(.caption)
                    }
                    Spacer()
                    Text(product.displayPrice).bold().padding(0)
                }
                .foregroundColor(product.id == "monthly_001" ? .white : .primary)
                .background(Color.accentColor.gradient.opacity(product.id == "monthly_001" ? 1 : 0.1))
                .cornerRadius(10)
            }
        }
    }
    
    
    func buy(_ product: Product) async {
        do {
            if try await storeVM.purchase(product) != nil {
                isPurchased = true
            }
        } catch {
            print("purchase failed")
        }
    }
}

struct PurchaseView: View {
    var title: String = ""
    var subtitle: String = ""
    
    let bg = Color(.systemBackground)
    let accent = Color.accentColor
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        Image(systemName: "flame.circle.fill")
                            .resizable()
                            .foregroundStyle(Color.accentColor.gradient)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                            .frame(maxWidth: 60)
                        Spacer()
                    }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    Text("Gas Alert Plus")
                        .font(.system(.title, design: .rounded))
                        .bold()
                        // inner shadow
//                        .foregroundColor(.white)
                        .foregroundStyle(
                            Color.accentColor.gradient
                                .shadow(.inner(color: .white.opacity(0.5), radius: 2, x: 0, y: 0))
                        )
//                        .font(.title)
//                        .bold()
                        .padding(.bottom, 10)
                    VStack(alignment: .leading) {
                        Text ("Gas Alert Plus gives you unlimited alerts and more features.")
                        Text ("Your support let's us work on the app and pay for our servers, keeping everything running smoothly.")
                    }
                        .padding()
                    Divider()
                    
//                    HStack {
//                        Spacer()
//                    }
                    Text("Here's what you will get now").font(.title2).bold()
                        .padding()
                    GoodStuff()
                    
                    Divider().padding(.top, 5)
                    Text("What's coming in the future").font(.title2).bold()
                        .padding()
                    NextGoodStuff()
                    
                    VStack(spacing: 10) {
                        HStack(spacing: 30) {
                            Link("Terms", destination: URL(string: "https://sites.google.com/view/gasfeetracker/terms-conditions")!)
                            Link("Privacy", destination: URL(string: "https://sites.google.com/view/gasfeetracker/privacy-policy")!)
                            Button("Restore", action: {
                                Task {
                                    try? await AppStore.sync()
                                }
                            })
                        }
                    }.padding().font(.caption)
                    Spacer(minLength: 25)
//                    VStack {
//                        Spacer()
//                        VStack {
//                            BuyButtons().padding(.top, 10)
//                            Text("Cancel anytime. No strings attached.").font(.caption2)
//                //            Spacer()
//                        }.background(Color(.systemBackground))
//                    }.opacity(0).disabled(true)
                }.padding()
            }
            Divider()
            VStack {
                BuyButtons()
                Text("Cancel anytime. No strings attached.").font(.caption)
    //            Spacer()
            }.background(Color(.systemBackground)).padding()
        }
        
    }
}


struct FeatureView: View {
    let systemName: String
    let featureName: String
    let iconColor: Color
    
    var body: some View {
//        HStack {
//            Image(systemName: systemName)
//                .frame(width: 32, height: 32)
//                .background(Color(.systemGray), in: RoundedRectangle(cornerRadius: 8))
//                .foregroundColor(.white)
//
//            Button(featureName, action: action)
//                .foregroundColor(.primary)
//                .disabled(true)
//        }
//        .opacity(0.5)
        
        HStack {
            Image(systemName: systemName)
                .frame(width: 32, height: 32)
                .foregroundColor(iconColor)
                .background(iconColor.opacity(0.1))
                .cornerRadius(7)
            Text(featureName)
        }.opacity(0.5)
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
            PurchaseView(
                title: "Get full access",
                subtitle: ""
            ).environmentObject(StoreVM())
            .padding()
    }
}
