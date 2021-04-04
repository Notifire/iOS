//
//  NavigationBarDisplaying.swift
//  Notifire
//
//  Created by David Bielik on 05/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

protocol NavigationBarDisplaying {}

extension NavigationBarDisplaying where Self: UIViewController {

    /// Hides the navigation bar from the current `UIViewController`
    func hideNavigationBar(showSeparator: Bool = false) {
        guard let navigationController = navigationController else { return }
        navigationController.hideNavigationBar()
        if showSeparator {
            addNavigationBarSeparator()
        }
    }

    /// Shows the navigation bar in the current `UIViewController`
    func showNavigationBar() {
        guard let navigationController = navigationController else { return }
        navigationController.showNavigationBar()
    }

    /// Adds the separator for a navigation bar that is hidden
    /// - Note:
    ///     - Usually call this after adding all subviews to make sure this view is on top of all of them.
    @discardableResult
    func addNavigationBarSeparator() -> SeparatorView {
        let separator = SeparatorView()
        view.add(subview: separator)
        separator.embedSides(in: view)
        separator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        return separator
    }

    /// Hides the back button text from the navigation bar (but keeps the chevron).
    /// - Important: Call this on the ViewController that will present another one.
    ///              In other words, this function hides the text on the next pushed VC.
    /// - Parameters:
    ///     - newBackBarText: the text that should be used for `.minimal` backButtonDisplayModes.
    func hideNavigationBarBackButtonText(newBackBarText: String? = nil) {
        if #available(iOS 14, *) {
            if let newText = newBackBarText {
                navigationItem.backButtonTitle = newText
            }
            navigationItem.backButtonDisplayMode = .minimal
        } else {
            navigationItem.backButtonTitle = ""
        }
    }
}
