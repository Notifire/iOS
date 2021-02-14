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

    func insert(subview: UIView, belowSubview: UIView) {
        insertSubview(subview, belowSubview: belowSubview)
        subview.translatesAutoresizingMaskIntoConstraints = false
    }

    func insert(subview: UIView, aboveSubview: UIView) {
        insertSubview(subview, aboveSubview: aboveSubview)
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
        tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 0.5))
    }

    /// Reload the tableView data without moving the contentOffest the user has currently scrolled to.
    func reloadDataWithoutMoving() {
        setContentOffset(contentOffset, animated: false)
        // Save current
        let beforeContentSize = contentSize
        reloadData()
        layoutIfNeeded()
        let afterContentSize = contentSize
        let offset = CGPoint(x: 0, y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        contentOffset = offset
    }
}
