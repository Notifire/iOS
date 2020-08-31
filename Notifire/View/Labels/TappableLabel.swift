//
//  TappableLabel.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class TappableLabel: UILabel {
    
    // MARK: - Properties
    var linkedRange: NSRange?
    private let fontSize: CGFloat
    
    // MARK: - Inherited
    init(fontSize: CGFloat) {
        self.fontSize = fontSize
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.fontSize = 13
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Private
    private func setup() {
        isUserInteractionEnabled = true
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(recognizer:)))
        recognizer.minimumPressDuration = 0.2
        addGestureRecognizer(recognizer)
    }
    
    @objc private func didLongPress(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            onLabelLongPress()
        case .failed, .cancelled, .ended:
            onLabelLongPressEnded()
        case .changed, .possible: break
        }
    }
    
    private func changeLink(color: UIColor) {
        guard let text = attributedText, let range = linkedRange else { return }
        let mutableAttributedString = NSMutableAttributedString(attributedString: text)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        attributedText = mutableAttributedString
    }
    
    private func onLabelLongPress() {
        changeLink(color: UIColor.notifireMainColor.withAlphaComponent(0.5))
    }
    
    private func onLabelLongPressEnded() {
        changeLink(color: .notifireMainColor)
    }
    
    private func setLinkedAttributedText(text: String, link: String, color: UIColor) -> Bool {
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
        let rangeOfLinkedText = attributedString.mutableString.range(of: link)
        
        guard rangeOfLinkedText.location != NSNotFound else { return false }
        linkedRange = rangeOfLinkedText
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: rangeOfLinkedText)
        attributedText = attributedString
        return true
    }
    
    // MARK: - Public
    @discardableResult
    public func setLinked(text: String, link: String) -> Bool {
        return setLinkedAttributedText(text: text, link: link, color: .notifireMainColor)
    }
}
