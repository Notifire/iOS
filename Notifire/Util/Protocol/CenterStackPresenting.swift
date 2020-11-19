//
//  CenterStackPresenting.swift
//  Notifire
//
//  Created by David Bielik on 13/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol CenterStackViewPresenting {
    var stackViewSuperview: UIView { get }
    func insertStackView(arrangedSubviews: [UIView], spacing: CGFloat, priority: UILayoutPriority) -> UIStackView
}

extension CenterStackViewPresenting {

    /// convenience function for adding a stackview that has equal centerXanchor with it's superview
    @discardableResult
    func insertStackView(arrangedSubviews: [UIView], spacing: CGFloat = Size.componentSpacing, priority: UILayoutPriority = .required) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews, spacing: spacing)
        stackViewSuperview.add(subview: stackView)
        stackView.centerXAnchor.constraint(equalTo: stackViewSuperview.centerXAnchor).with(priority: priority).isActive = true
        func setEqualWidth(subview: UIView) {
            if let stackView = subview as? UIStackView {
                stackView.arrangedSubviews.forEach { setEqualWidth(subview: $0) }
            } else if (subview is NotifireButton) || !(subview is UIButton) {
                subview.widthAnchor.constraint(equalTo: stackViewSuperview.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).with(priority: priority).isActive = true
            }
        }
        arrangedSubviews.forEach { setEqualWidth(subview: $0) }
        return stackView
    }
}

extension CenterStackViewPresenting where Self: UIViewController {
    var stackViewSuperview: UIView {
        return view
    }
}

extension CenterStackViewPresenting where Self: UIView {
    var stackViewSuperview: UIView {
        return self
    }
}
