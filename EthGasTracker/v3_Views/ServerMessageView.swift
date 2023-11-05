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
        TabView(selection: $index) {
            ForEach(messages.indices, id: \.self) { msgItem in
                ServerMessageView(
                    url: messages[msgItem].url,
                    image: messages[msgItem].image,
                    title: messages[msgItem].title,
                    text: messages[msgItem].body
                )
                .tag(msgItem)
            }
        }
        .frame(height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(
            HStack {
                if (messages.count > 1) {
                    ForEach(messages.indices, id: \.self) { msgItem in
                        Circle()
                            .fill(Color.primary.opacity(index == msgItem ? 0.7 : 0.4))
                            .frame(width: index == msgItem ? 6 : 4, height: index == msgItem ? 6 : 4)
                    }
                }
            }
                .offset(y: 50)
        )
        .onChange(of: messages.count) { theCount in
            timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
                withAnimation {
                    index = (index + 1) % theCount
                }
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
            Spacer()
            Image(systemName: "arrow.up.right")
                .padding(.trailing)
                .opacity(isLink! ? 1 : 0)
        }
        .frame(height: 60)
        .foregroundColor(.primary)
        .background(Color(.systemBackground))
//        .background(.ultraThinMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        }
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
