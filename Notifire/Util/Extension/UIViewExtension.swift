//
//  UIViewExtension.swift
//  Notifire
//
//  Created by David Bielik on 11/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

extension UIView {
    /// Convenience function for adding a subview that is going to be managed by autolayout
    func add(subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
    }

    func toCircle() {
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
}

extension UIImageView {
    convenience init(notifireImage: UIImage) {
        self.init()
        self.image = notifireImage.withRenderingMode(.alwaysTemplate)
        self.tintColor = .spinnerColor
    }
}

extension UIEdgeInsets {
    init(everySide size: CGFloat) {
        self.init(top: size, left: size, bottom: size, right: size)
    }
}

extension UITableView {
    func dontShowEmptyCells() {
        tableFooterView = UIView()
    }

    func removeLastSeparatorAndDontShowEmptyCells() {
        tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 1))
    }

    func reloadDataWithoutMoving() {
        let beforeContentSize = contentSize
        let beforeContentOffset = contentOffset
        reloadData()
        setNeedsLayout()
        layoutIfNeeded()
        let afterContentSize = contentSize
        let offset = CGPoint(x: 0, y: beforeContentOffset.y + (afterContentSize.height - beforeContentSize.height))
        contentOffset = offset
    }
}
