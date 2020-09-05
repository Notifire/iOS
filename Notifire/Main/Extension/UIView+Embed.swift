//
//  UIView+Embed.swift
//  Notifire
//
//  Created by David Bielik on 04/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension UIView {
    /// Embeds `self` in `superview` using autolayout constraints.
    func embed(in superview: UIView) {
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
    }

    /// Embeds `self`leading and trailing anchors in `superview` leading and trailing anchors using autolayout constraints.
    func embedSides(in superview: UIView) {
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }

    /// Embeds `self`leading and trailing anchors in `superview` layoutMarginGuides using autolayout constraints.
    func embedSidesInMargins(in superview: UIView) {
        leadingAnchor.constraint(equalTo: superview.layoutMarginsGuide.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.layoutMarginsGuide.trailingAnchor).isActive = true
    }
}
