//
//  TappableLabel.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

/// The Label class that contains a hypertext that can be tapped or long-pressed to trigger some action.
class TappableLabel: UILabel {

    // MARK: - Properties
    /// The range of the hypertext.
    private var hypertextRange: NSRange?
    /// The location of a long press touch when it began.
    private var touchesBeganLocation: CGPoint?

    private struct Constant {
        // MARK: Animation
        static let highlightColor = UIColor.systemGray.withAlphaComponent(0.3)
        static let cornerRadius: CGFloat = 4

        static let forwardDuration: TimeInterval = 0.1
        static let backwardDuration: TimeInterval = 0.05

        // MARK: Other
        static let touchInsetBy: CGFloat = -10
    }
    var hypertextOverlayView: UIView?

    // MARK: Actions
    /// The callback whenever the hypertext is tapped / long-pressed
    public var onHypertextTapped: (() -> Void)?

    // MARK: - Inherited
    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Private
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        lineBreakMode = .byTruncatingMiddle
        // Enable user interaction
        isUserInteractionEnabled = true
        set(style: .primary)

        // Add gesture recognizer for tapping on the hypertext
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(recognizer:)))
        recognizer.minimumPressDuration = 0
        addGestureRecognizer(recognizer)
    }

    // MARK: LongPressGesture
    @objc private func didLongPress(recognizer: UILongPressGestureRecognizer) {
        let locationInView = recognizer.location(in: self)
        switch recognizer.state {
        case .began:
            guard let boundingRect = boundingRectForHypertextRange(), boundingRectContains(boundingRect, touch: locationInView) else { return }
            touchesBeganLocation = locationInView
            onLabelLongPress(hypertextRect: boundingRect)
        case .changed:
            // Check if the touch haven't moved out of bounds (inset by -10).
            guard
                !(hypertextOverlayView?.frame.insetBy(dx: Constant.touchInsetBy, dy: Constant.touchInsetBy).contains(locationInView) ?? false)
            else { return }
            // If it did, end the gesture.
            onLabelLongPressEnded(location: nil)
        case .failed, .cancelled, .ended:
            onLabelLongPressEnded(location: locationInView)
        default: break
        }
    }

    private func onLabelLongPress(hypertextRect: CGRect) {
        guard hypertextOverlayView == nil else { return }
        let hypertextOverlayView = UIView(frame: hypertextRect)
        insertSubview(hypertextOverlayView, at: 0)
        hypertextOverlayView.layer.cornerRadius = Constant.cornerRadius
        self.hypertextOverlayView = hypertextOverlayView
        UIView.animate(withDuration: Constant.forwardDuration, delay: 0, options: [.curveEaseIn], animations: {
            hypertextOverlayView.backgroundColor = Constant.highlightColor
        }, completion: nil)
    }

    /// Called when the long press ends.
    /// - Parameters:
    //      - location: the `CGPoint` location of the touch.
    private func onLabelLongPressEnded(location: CGPoint?) {
        guard let highlightedHypertextView = hypertextOverlayView else { return }
        UIView.animate(withDuration: Constant.backwardDuration, delay: 0, options: [.curveEaseOut], animations: {
            highlightedHypertextView.backgroundColor = .clear
        }, completion: { [weak self] _ in
            self?.hypertextOverlayView?.removeFromSuperview()
            self?.hypertextOverlayView = nil
        })
        touchesBeganLocation = nil
        guard
            let boundingRect = boundingRectForHypertextRange(),
            let location = location,
            boundingRectContains(boundingRect, touch: location) else { return }
        onHypertextTapped?()
    }

    // MARK: Bounding Box
    private func setLinkedAttributedText(text: String, link: String, color: UIColor) {
        let defaultFont = font ?? UIFont.systemFont(ofSize: Size.Font.default)
        let defaultColor: UIColor = textColor ?? .compatibleSecondaryLabel
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: defaultFont,
            NSAttributedString.Key.foregroundColor: defaultColor
        ])
        let rangeOfLinkedText = attributedString.mutableString.range(of: link)

        guard rangeOfLinkedText.location != NSNotFound else { return }
        hypertextRange = rangeOfLinkedText
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: rangeOfLinkedText)
        let actionFont = UIFont.systemFont(ofSize: defaultFont.pointSize, weight: .medium)
        attributedString.addAttribute(NSAttributedString.Key.font, value: actionFont, range: rangeOfLinkedText)
        attributedText = attributedString
    }

    private func boundingRectForHypertextRange() -> CGRect? {
        guard let attributedText = attributedText, let text = text, let range = hypertextRange else { return nil }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()

        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0

        layoutManager.addTextContainer(textContainer)

        var glyphRange = NSRange()

        // Convert the range for glyphs.
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        // Check if there is some vertical padding
        var fullTextGlyphRange = NSRange()
        let fullTextRange = NSMutableAttributedString(attributedString: attributedText).mutableString.range(of: text)
        layoutManager.characterRange(forGlyphRange: fullTextRange, actualGlyphRange: &fullTextGlyphRange)
        let labelTextBoundingRect = layoutManager.boundingRect(forGlyphRange: fullTextGlyphRange, in: textContainer)
        let labelTextBoundingRectHeight = labelTextBoundingRect.height.rounded(.up)
        if bounds.height > boundingRect.height.rounded(.up), bounds.height > labelTextBoundingRectHeight {
            // If there is, add it to the boundingRect's origin
            let padding = (bounds.height - labelTextBoundingRectHeight) / 2
            let paddedBoundingRectOrigin = CGPoint(x: 0, y: padding)
            let paddedBoundingRect = CGRect(origin: paddedBoundingRectOrigin, size: boundingRect.size)
            return paddedBoundingRect.insetBy(dx: -2, dy: -2)
        }
        return boundingRect.insetBy(dx: -2, dy: -2)
    }

    /// Boolean function that returns `True` if the touch location was inside the enlarged bounding box of the hypertext.
    /// - Note: bounding box is enlarged to ease the precision of the user tap.
    private func boundingRectContains(_ boundingRect: CGRect, touch location: CGPoint) -> Bool {
        return boundingRect.insetBy(dx: Constant.touchInsetBy, dy: Constant.touchInsetBy).contains(location)
    }

    // MARK: - Public
    /// Creates an attributed string that has `link` highlighted. Tapping on this part of the text will trigger the `onHypertextTapped` action.
    public func set(hypertext: String, in text: String) {
        setLinkedAttributedText(text: text, link: hypertext, color: .primary)
    }
}
