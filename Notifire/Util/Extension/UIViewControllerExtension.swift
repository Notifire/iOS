//
//  UIViewControllerExtension.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

extension UIViewController {

    /// Convenience function that embeds a subview into viewcontroller's safeAreaLayoutGuide
    func embedInSafeAreaLayoutGuide(subview: UIView) {
        let safeGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor),
            subview.topAnchor.constraint(equalTo: safeGuide.topAnchor),
            safeGuide.bottomAnchor.constraint(equalTo: subview.bottomAnchor)
            ])
    }

    /// Convenience function for adding a child view controller to the hierarchy
    func add(childViewController child: UIViewController, superview: UIView? = nil) {
        addChild(child)
        let vcSuperview: UIView = superview ?? view
        vcSuperview.addSubview(child.view)
        child.didMove(toParent: self)
    }

    /// Convenience function for removing a child view controller from viewcontroller's view hierarchy
    func remove(childViewController child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

    /// Class function that returns all of the child view controllers recursively.
    class func getAllChildren<T: UIViewController>(vc: UIViewController) -> [T] {
        return vc.children.flatMap { childVC -> [T] in
            var result = getAllChildren(vc: childVC) as [T]
            if let vc = childVC as? T { result.append(vc) }
            return result
        }
    }

    func getNestedChildren<T: UIViewController>() -> [T] {
        return UIViewController.getAllChildren(vc: self)
    }
}

extension UIViewController {

    /// Adds a tap gesture recognizer which causes the keyboard to be dismissed to the parameter.
    @discardableResult
    func addKeyboardDismissOnTap(to hideOnTouchView: UIView) -> UIGestureRecognizer {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        hideOnTouchView.addGestureRecognizer(tapRecognizer)
        return tapRecognizer
    }

    /// Dismisses the keyboard.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
