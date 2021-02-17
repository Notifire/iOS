//
//  PreferredContentSizeAutochanging.swift
//  Notifire
//
//  Created by David Bielik on 17/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

/// Describes `UIViewController` objects that automatically change their preferredContentSizeObserver depending on their scroll / tableview contentSize.
protocol PreferredContentSizeAutochanging: UIViewController {
    /// The observer for the preferredContentSize
    var preferredContentSizeObserver: NSKeyValueObservation? { get set }
    var contentSizeView: UIScrollView { get }
}

extension PreferredContentSizeAutochanging {

    /// Creates and sets an observer for the `contentSizeView`'s `contentSize` into `preferredContentSizeObserver`
    func createAndSetPreferredContentSizeObserver() {
        guard preferredContentSizeObserver == nil else { return }

        preferredContentSizeObserver = contentSizeView.observe(\.contentSize, options: [.initial, .new], changeHandler: { [weak self] (scrollView, _) in
            self?.preferredContentSize = scrollView.contentSize
        })
    }

    /// Invalidates the `preferredContentSizeObserver` and sets it to `nil`.
    func invalidatePreferredContentSizeObserver() {
        preferredContentSizeObserver?.invalidate()
        preferredContentSizeObserver = nil
    }

}
