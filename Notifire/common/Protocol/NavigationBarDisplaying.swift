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
    func hideNavigationBar() {
        guard let navigationController = navigationController as? NavigationBarProviding else { return }
        navigationController.hideNavigationBar()
    }

    /// Shows the navigation bar in the current `UIViewController`
    func showNavigationBar() {
        guard let navigationController = navigationController as? NavigationBarProviding else { return }
        navigationController.showNavigationBar()
    }

    /// Hides the back button text from the navigation bar (but keeps the chevron).
    func hideNavigationBarBackButtonText() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
