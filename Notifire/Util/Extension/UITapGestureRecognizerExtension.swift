//
//  UITapGestureRecognizerExtension.swift
//  Notifire
//
//  Created by David Bielik on 28/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

extension UITapGestureRecognizer {

    func didTapAttributedText(in tappableLabel: TappableLabel) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        guard let attributedText = tappableLabel.attributedText else { return false }
        let textStorage = NSTextStorage(attributedString: attributedText)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = tappableLabel.lineBreakMode
        textContainer.maximumNumberOfLines = tappableLabel.numberOfLines
        let labelSize = tappableLabel.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: tappableLabel)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard let targetRange = tappableLabel.linkedRange else { return false }
        return NSLocationInRange(indexOfCharacter, targetRange)
    }

}
