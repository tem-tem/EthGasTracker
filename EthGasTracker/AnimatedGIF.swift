//
//  AnimatedGif.swift
//  EthGasTracker
//
//  Created by Tem on 3/22/23.
//

import Foundation
import SwiftUI
import UIKit
import ImageIO
import MobileCoreServices

struct AnimatedGIF: UIViewRepresentable {
    let imageName: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage.animatedImage(withAnimatedGIFURL: Bundle.main.url(forResource: imageName, withExtension: "gif")!)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

extension UIImage {
    static func animatedImage(withAnimatedGIFURL gifURL: URL) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(gifURL as CFURL, nil) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: TimeInterval = 0.0

        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
                let gifInfo = properties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
                let delayTime = gifInfo?[kCGImagePropertyGIFDelayTime as String] as? TimeInterval ?? 0.0

                images.append(UIImage(cgImage: image))
                duration += delayTime
            }
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }
}
