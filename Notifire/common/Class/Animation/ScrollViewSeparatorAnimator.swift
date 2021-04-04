//
//  ScrollViewSeparatorAnimator.swift
//  Notifire
//
//  Created by David Bielik on 04/04/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

/// Handles the hiding/showing animation of a Separator `UIView` depending on the `scrollView.contentOffset.y`
class ScrollViewSeparatorAnimator {

    // MARK: - Properties
    weak var separator: UIView? {
        didSet {
            self.hidden = separator?.alpha == 0
        }
    }

    /// Whether the separator is currently shown or hidden.
    private var hidden: Bool = false

    // MARK: - Private
    // We don't need to trigger the computation every time the delegate invokes the method.
    private func shouldConsiderScroll(contentOffset: CGPoint) -> Bool {
        return Int(contentOffset.y) % 3 == 0
    }

    // MARK: - Public
    public func handleScrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldConsiderScroll(contentOffset: scrollView.contentOffset) else { return }
        let shouldShowSeparator = scrollView.contentOffset.y != 0
        let shouldHideSeparator = !shouldShowSeparator

        if (shouldShowSeparator || scrollView.isTracking), hidden {
            hidden = false
            UIView.animate(withDuration: 0.15) {
                self.separator?.alpha = 1
            }
        } else if shouldHideSeparator, !hidden {
            hidden = true
            UIView.animate(withDuration: 0.2, delay: 1, options: [], animations: {
                self.separator?.alpha = 0
            }, completion: nil)
        }
    }
}
