//
//  UIHyperTextView.swift
//  Notifire
//
//  Created by David Bielik on 23/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class UIHyperTextView: UITextView {

    // MARK: - Properties
    override var font: UIFont? {
        didSet {
            setupLinkTextAttributes()
        }
    }

    var hyperTextFont: UIFont {
        return UIFont.systemFont(ofSize: font?.pointSize ?? Size.Font.default, weight: .medium)
    }

    /// Prevent copying / selection of the text.
    /// https://stackoverflow.com/questions/1896340/disable-text-selection-uitextview
    override var canBecomeFirstResponder: Bool {
        return false
    }

    // MARK: - Initialization
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Private
    private func setup() {
        attributedText = NSAttributedString()
        font = UIFont.systemFont(ofSize: 14)

        isEditable = false
        isScrollEnabled = false
        backgroundColor = .clear
        textAlignment = .center
    }

    private func setupLinkTextAttributes() {
        linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.primary,
            NSAttributedString.Key.font: hyperTextFont
        ]
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard
            #available(iOS 13.0, *),
            traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)
        else { return }
        let newColorAttributedText = NSMutableAttributedString(attributedString: attributedText)
        let range = NSRange(location: 0, length: newColorAttributedText.length)
        newColorAttributedText.addAttribute(.foregroundColor, value: UIColor.compatibleLabel, range: range)
        attributedText = newColorAttributedText
    }

    // MARK: - Public
    /// https://stackoverflow.com/a/60062348/4249857
    /// - Note: This func expects `textAlignment` to be set already.
    func addHyperLinksToText(originalText: String, hyperLinks: [String: String]) {
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment
        style.lineSpacing = 2
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        for (hyperLink, urlString) in hyperLinks {
            let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
            let fullRange = NSRange(location: 0, length: attributedOriginalText.length)
            attributedOriginalText.addAttribute(.link, value: urlString, range: linkRange)
            attributedOriginalText.addAttribute(.paragraphStyle, value: style, range: fullRange)
            attributedOriginalText.addAttribute(.font, value: font ?? UIFont.systemFont(ofSize: Size.Font.default), range: fullRange)
            attributedOriginalText.addAttribute(.font, value: hyperTextFont, range: linkRange)
        }

        self.attributedText = attributedOriginalText
    }
}
