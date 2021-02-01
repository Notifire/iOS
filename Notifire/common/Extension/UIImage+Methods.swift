//
//  UIImage+Resize.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension UIImage {

    /// Resizes `Self` to a new `CGSize`
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    // Credits: https://gist.github.com/brownsoo/1b772612b54c4dc58d88ae71aec19552
    func rounded(to radius: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        let result = renderer.image { _ in
            let rounded = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            rounded.addClip()
            if let cgImage = self.cgImage {
                UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation).draw(in: rect)
            }
        }
        return result
    }

    /// Creates a rounded `UIImage` with vertically and horizontally centered text.
    static func labelledImage(with text: String, font: UIFont, padding: CGFloat = 3) -> UIImage {
        // Calculate text bounds
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let constrainedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        let textBounds = attributedText.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, context: nil)
        let textHeight = textBounds.height.rounded(.up)
        let textWidth = max(textBounds.width.rounded(.up), textHeight)

        // Calculate image bounds
        let imageHeight = textHeight + 2*padding
        // Make sure the padding creates a circle if the text is only one digit / character
        let textPaddingMultiplier: CGFloat = text.count == 1 ? 1 : 1.5
        let imageWidth = textWidth + textPaddingMultiplier * padding * 2
        let imageSize: CGSize = CGSize(width: imageWidth, height: imageHeight)

        // CGRect for image and text
        let imageRect = CGRect(origin: .zero, size: imageSize)
        let textRect = CGRect(x: textPaddingMultiplier * padding, y: (imageHeight - font.lineHeight) / 2, width: textWidth, height: font.lineHeight)

        // Draw
        let textImage = UIGraphicsImageRenderer(size: imageSize).image { rendererContext in
            // Solid background
            UIColor.primary.setFill()
            rendererContext.fill(imageRect)
            // Text
            text.draw(with: textRect.integral, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        }
        return textImage.rounded(to: textImage.size.height)
    }
}
