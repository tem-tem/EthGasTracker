//
//  ChangelogView.swift
//  EthGasTracker
//
//  Created by Tem on 6/23/23.
//

import SwiftUI

struct ChangelogView: View {
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Text("Thank you for using the app 😤")
                    Section("What's new in this version") {
                        HStack (alignment: .top) {
                            Image(systemName: "square.grid.4x3.fill")
                                .frame(width: 32, height: 32)
                                .background(.orange, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("Heatmap Improvements").font(.headline)
                                    .padding(.bottom, 1)
                                Text("Enhanced statistics overview.\nUser Interface improvements.")
                            }
                        }
                    }
                    Section("version 2.5") {
                        HStack (alignment: .top) {
                            Image(systemName: "rectangle.3.group.fill")
                                .frame(width: 32, height: 32)
                                .background(Color("avg"), in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("Widgets").font(.headline)
                                    .padding(.bottom, 1)
                                Text("Introducing lock screen widgets, small, large, and medium-sized widgets.")
                            }
                        }
                        HStack (alignment: .top) {
                            Image(systemName: "bell.fill")
                                .frame(width: 32, height: 32)
                                .background(Color("high"), in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("More notifications").font(.headline)
                                    .padding(.bottom, 1)
                                Text("We've increased the notification limit to three.")
                            }
                        }
                        HStack (alignment: .top) {
                            Image(systemName: "bubble.left.fill")
                                .frame(width: 32, height: 32)
                                .background(Color("low"), in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("Feedback & Suggestions").font(.headline)
                                    .padding(.bottom, 1)
                                Text("Sharing your feedback and suggestions within the app is now easier than ever.")
                                Text("Tap on \(Image(systemName: "gear")), then select \(Image(systemName: "bubble.left"))\"Send Feedback and Suggestion\".")
                            }
                        }
                        HStack (alignment: .top) {
                            Image(systemName: "water.waves")
                                .frame(width: 32, height: 32)
                                .background(.teal, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("Haptic Feedback").font(.headline)
                                    .padding(.bottom, 1)
                                Text("We've added the option to disable haptic feedback.")
                                Text("Tap on \(Image(systemName: "gear")), then toggle the switch next to \(Image(systemName: "water.waves"))\"Haptic Feedback\".")
                            }
                        }
                        HStack (alignment: .top) {
                            Image(systemName: "figure.dance")
                                .frame(width: 32, height: 32)
                                .background(.orange, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("UI Improvements").font(.headline)
                                    .padding(.bottom, 1)
                                Text("We've made improvements to the user interface for a more enjoyable experience.")
                            }
                        }
                    }
                }.listStyle(.sidebar)
            }
            .navigationTitle("Changelog")
        }
    }
}

struct ChangelogView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogView()
    }
}
