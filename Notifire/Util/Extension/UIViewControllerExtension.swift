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

protocol NavigationBarDisplaying {}

extension NavigationBarDisplaying where Self: UIViewController {
    func hideNavBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
    }

    func showNavBar() {
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .backgroundAccentColor
    }

    func removeNavigationItemBackButtonTitle() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
