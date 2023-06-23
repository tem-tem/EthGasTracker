//
//  FeedbackButtonView.swift
//  EthGasTracker
//
//  Created by Tem on 6/20/23.
//

import SwiftUI
import MessageUI

struct FeedbackButton: View {
    @State private var isShowingMailView = false

    var body: some View {
        Button("Send Feedback & Suggestions") {
            self.isShowingMailView.toggle()
        }
        .foregroundColor(.primary)
        .disabled(!MFMailComposeViewController.canSendMail())
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: $isShowingMailView)
        }
    }
}

struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients(["gas.app.developers@gmail.com"])
        mail.setSubject("Feedback")
        mail.setMessageBody("", isHTML: false)

        return mail
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        // Nothing to update
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            parent.isShowing = false
        }
    }
}
