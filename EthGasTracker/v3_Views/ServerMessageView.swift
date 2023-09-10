//
//  ServerMessageView.swift
//  EthGasTracker
//
//  Created by Tem on 9/2/23.
//

import SwiftUI
import Snappable

struct ServerMessages: View {
    let messages: [ServerMessage]
    @State private var timer: Timer?
    @State private var index: Int = 0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollView in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(messages.indices, id: \.self) { msgItem in
                            ServerMessageView(
                                url: messages[msgItem].url,
                                image: messages[msgItem].image,
                                title: messages[msgItem].title,
                                text: messages[msgItem].body
                            )
                            .padding(.leading, msgItem == 0 ? geometry.size.width * 0.04 : 0)
                            .padding(.trailing, msgItem == messages.count - 1 ? geometry.size.width * 0.04 : 0)
                            .snapID(msgItem)
                            .frame(width: messages.count > 1 ? geometry.size.width * 0.92 : geometry.size.width)
                        }
                    }
                }
                .snappable(alignment: .center)
//                .onAppear {
//                    timer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { _ in
//                        if index < messages.count - 1 {
//                            index += 1
//                        } else {
//                            index = 0
//                        }
//                        withAnimation {
//                            scrollView.scrollTo(index, anchor: .center)
//                        }
//                    }
//                }
//                .onDisappear {
//                    timer?.invalidate()
//                }
            }
        }
    }
}

struct MessageContentView: View {
    let image: String
    let title: String
    let text: String
    var isLink: Bool? = false
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: image)) { image in
                image.resizable().scaledToFill().clipped()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 60)
//                .cornerRadius(5)
            VStack (alignment: .leading) {
                Text(title).bold()
                Text(text).multilineTextAlignment(.leading)
                    .lineSpacing(-9)
            }
                .font(.caption)
            if (isLink == true) {
                Spacer()
                Image(systemName: "arrow.up.right")
                    .padding(.trailing)
            }
        }
        .foregroundColor(.primary)
        .background(Color.primary.opacity(0.1))
        .cornerRadius(5)
        .padding(.horizontal, 5)
    }
}

struct ServerMessageView: View {
    let url: String
    let image: String
    let title: String
    let text: String
    
    var body: some View {
        if (url.isEmpty) {
            MessageContentView(image: image, title: title, text: text)
        } else {
            Link(destination: URL(string: url)!) {
                MessageContentView(image: image, title: title, text: text, isLink: true)
            }
        }
        
    }
}

struct ServerMessages_Previews: PreviewProvider {
    static let msExamples: [ServerMessage] = [
        ServerMessage(title: "HOW-TO", body: "Please, be patient. For issues or suggestions, see links in Settings.", url: "", image: "https://images.unsplash.com/photo-1693459679879-0aec769723c7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2487&q=80")
//        ServerMessage(title: "HOW-TO", body: "blblasjdlaksjdlaksjd laksjdlk ajs", url: "https://www.apple.com", image: "https://images.unsplash.com/photo-1693459679879-0aec769723c7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2487&q=80")
//        ServerMessage(title: "HOW-TO", body: "blblasjdlaksjdlaksjd laksjdlk ajs", url: "https://www.apple.com", image: "https://images.unsplash.com/photo-1693459679879-0aec769723c7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2487&q=80")
    ]
    static var previews: some View {
        ServerMessages(messages: msExamples)
    }
}
